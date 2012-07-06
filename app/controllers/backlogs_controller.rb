include ItemsHelper

class BacklogsController < ApplicationController
  unloadable
  before_filter :find_backlog, :only => [:show, :update]
  before_filter :find_project, :authorize
  
  def index
    get_hash(@project.id)
    @all_items = Item.find_by_project(@project)
    @item_template = Item.new
    @backlogs = Backlog.find_by_project(@project, (params[:show_accepted_backlogs] ? nil : 3))
    @product_backlog = Backlog.find_product_backlog(@project)
    @backlog_l = Backlog.find(params[:backlog_l]) unless params[:backlog_l].blank?
    @backlog_r = Backlog.find(params[:backlog_r]) unless params[:backlog_r].blank?
    @show_accepted_backlogs = params[:show_accepted_backlogs] ? params[:show_accepted_backlogs] : false
    @back = url_for(:controller => 'backlogs', :action => 'index')
    
    list_backlog_items
  end

  def show
    render :json => @backlog.to_json(:methods => [:description, :end_date, :eta, :name]) 
  end
  
  def update
    @backlog = Backlog.update params
    render :json => @backlog.to_json(:methods => [:description, :end_date, :eta, :name]) 
  end

  private
  
  def find_project
    @project = params[:project_id].nil? ? Backlog.find(params[:id]).version.project : Project.find(params[:project_id])
  end
  
  def find_backlog
    @backlog = (params[:id]=='0' || params[:id].nil?) ? nil : Backlog.find(params[:id])
  end
  

  def list_backlog_items
    @items = {}
    @backlogs.each do |backlog|
      tmp_items = @all_items.select {|i| i.backlog_id.eql?(backlog.id)}
      citems = []
      items = tmp_items.reject do |item|
        citems << item if item.is_child?
        item if item.is_child? and tmp_items.include?(item.parent_item)
      end
      @items[backlog.id] = {:pitems => items, :citems => citems}
      Item.set_ideal_items_positions(items, citems)
    end
    
    tmp_items = @all_items.select {|i| i.backlog_id.eql?(0) or (@product_backlog and i.backlog_id.eql?(@product_backlog.id))}
    citems = []
    items = tmp_items.reject do |item|
      citems << item if item.is_child?
      item if item.is_child? and tmp_items.include?(item.parent_item)
    end
    @items[:backlog] = {:pitems => items, :citems => citems}
    Item.set_ideal_items_positions(items, citems)
  end
end
