class ItemsController < ApplicationController
  unloadable
  before_filter :find_item, :only => [:edit, :update, :show, :delete]
  before_filter :find_project, :authorize
  
  helper :backlogs
  
  def index
    render :text => "We don't do no indexin' round this part of town."
  end
  
  def create
    item = Item.create(params, @project)
    render :partial => "item", :locals => { :item => item }
  end

  def update
    @product_backlog = Backlog.find_product_backlog(@project)
    item = nil
    flag = true
    begin
      item = Item.update(params)
    rescue ActiveRecord::StaleObjectError
      # Optimistic locking exception
      flag = false
    end
    curr = Item.find(params[:id]).issue
    if !curr.children.empty? #ensure that children follows parent
      curr.children.each{|i| i.fixed_version_id = curr.fixed_version_id; i.save!}
    end
    if flag
      render :partial => "item", :locals => { :item => item } 
    else
      render :text => "409 Error", :status => 409
    end
  end
  
  private
  
  def find_project
    @project = if params[:project_id].nil?
                 @item.issue.project
               else
                 Project.find(params[:project_id])
               end
  end
  
  def find_item
    @item = Item.find(params[:id])
  end  
end
