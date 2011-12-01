class Item < ActiveRecord::Base
  unloadable
  belongs_to   :issue
  belongs_to   :backlog
  acts_as_list :scope => 'backlog_id=#{backlog_id} AND parent_id=#{parent_id}'
  acts_as_tree :order => "position ASC, created_at ASC"

  def append_comment(user, comment)
    journal = issue.init_journal(User.current, @notes)
  end

  def self.create(params, project)
    issue = create_issue(params, project)
    item  = find_by_issue_id(issue.id)
    item.update_attributes! params[:item]
    item.update_position params
    item
  end
  
  def subject
    issue.nil? ? "" : issue.subject
  end
  
  def self.update(params)
    item = find(params[:id])
    journal = item.issue.init_journal(User.current, @notes)
    
    # Fix bug #42 to remove this condition
    if params[:item][:backlog_id].to_i != 0
      params[:issue][:fixed_version_id] = Backlog.find(params[:item][:backlog_id]).version.id
    else
      params[:issue][:fixed_version_id] = ""
      params[:item].delete(:backlog_id)
    end

    default_status = item.issue.status
    allowed_statuses = if User.new.respond_to?(:roles_for_project)
                         ([default_status] + default_status.find_new_statuses_allowed_to(User.current.roles_for_project(item.issue.project), item.issue.tracker)).uniq
                       else
                         item.issue.new_statuses_allowed_to(User.current)
                       end
    requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
    
    # Check that the user is allowed to apply the requested status
    unless allowed_statuses.include? requested_status
      params[:issue].delete(:status_id)
    end
    
    if item.points != params[:item][:points].to_i
      journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'story_points', :old_value => item.points, :value => params[:item][:points])
    end 
    
    item.issue.update_attributes! params[:issue]
    item.remove_from_list    
    item.update_attributes! params[:item]
    item.update_position params
    item
  end

  def self.create_issue(params, project)
    issue = Issue.new
    issue.project = project

    # Tracker must be set before custom field values
    issue.tracker ||= project.trackers.find(params[:issue][:tracker_id])

    if params[:issue].is_a?(Hash)
      issue.attributes = params[:issue]
      issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, project)
    end
    issue.author = User.current
    
    default_status = IssueStatus.default
    issue.status = default_status
    allowed_statuses = if User.new.respond_to?(:roles_for_project)
                         ([default_status] + default_status.find_new_statuses_allowed_to(User.current.roles_for_project(project), issue.tracker)).uniq
                       else
                         issue.new_statuses_allowed_to(User.current)
                       end
    requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
    
    # Check that the user is allowed to apply the requested status
    issue.status = (allowed_statuses.include? requested_status) ? requested_status : default_status
    
    issue.save    
    issue.reload
    issue
  end

  def self.delete_item(issue)
    find_by_issue_id(issue.id).destroy
  end

  def self.find_by_project(project)
    items = find(:all, :include => :issue, :conditions => "issues.project_id=#{project.id} and parent_id=0", :order => "position ASC")
    update_same_positioned_items(items)
  end

# this method updates all items with the same position to avoid duplicate position that highly affects the drag n drop ordering of items.
  def self.update_same_positioned_items(items)
    temp = []
    dups = []
    items.map(&:position).each do |pos| #map only positions
      if !temp.member?(pos) # store a single copy of a position
        temp << pos
      else # add to duplicates
        dups << pos
      end
    end
    last_pos = (temp.compact - dups.compact.uniq).sort.last.to_i #get last position from uniq positions, reject duplicates first
    items.each do |item|
      if dups.uniq.member?(item.position) # if item position has duplicate, update
        last_pos += 1
        item.position = last_pos
        item.save
      end
    end
  end

  def self.remove_with_issue(issue)
    find_by_issue_id(issue.id).destroy
  end

  def self.update_from_issue(issue)
    backlog         = Backlog.find_by_version_id(issue.fixed_version_id)
    item            = find_by_issue_id(issue.id) || Item.new()
    item.issue_id   = issue.id
    item.backlog_id = (backlog.nil? ? 0 : backlog.id)
    item.save 
  end  
  
  def determine_new_position(params)
    if params[:prev]=="" || params[:prev].nil?
      1
    else
      prev = Item.find(params[:prev]).position
      prev + 1
    end
  end
  
  def update_position(params)
    insert_at determine_new_position(params)
  end
  
  def is_child?
    issue.parent.present?
  end
  
  def is_parent?
    issue.children.any?
  end
  
  def parent_item
    Item.find(:first, :conditions => ["issue_id = ?", issue.parent_issue.id]) if issue.parent
  end
  
  #TODO: Refactor query
  def children
    if issue.children.any?
      arr = issue.children.collect {|c| c.id }.join(', ')
      items = Item.find(:all, :conditions => ["issue_id in (#{arr}) "] )
    else
      []
    end
  end
  
  #def self.sort_by_parent(items)
  #  sorted = {}
  #  items.each do |item|
  #    if item.is_child? and items.include?(item.parent_item)
  #      sorted[item.parent_item] ||= []
  #      sorted[item.parent_item] << item
  #    else
  #      sorted[item] = []
  #    end
  #  end
  #  i = 0;
  #  sorted.each do |parent, children|
  #    parent.position = i+1;
  #    parent.save
  #    i=i+1;
  #    children.each do |c|
  #      c.position = i+1
  #      c.save
  #      i=i+1
  #    end unless children.empty?
  #  end
  #end
  
  def self.sort_by_parent(items)
    sorted = []
    items.each_with_index do |item, c|
      if item.is_child? && sorted.include?(item.parent_item)
        parent_index = sorted.index(item.parent_item)
        sorted.insert(parent_index + 1, item)
      elsif item.is_child?
        parent_index = items.index(item.parent_item)
        items.slice!(parent_index)
        sorted << item.parent_item
        sorted << item
      else
        sorted << item
      end
    end
    pos = 0
    sorted.each do |s|
      pos = pos + 1
      s.position = pos
      s.save
    end unless sorted.empty?
  end
end
