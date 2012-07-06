class ItemsController < ApplicationController
include ItemsHelper
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
    get_hash
    @product_backlog = Backlog.find_product_backlog(@project)
    params[:user_id] = User.current.id
    temp = Item.find params[:id]
    if params[:issue][:status_id] and params[:issue][:status_id] != temp.issue.status_id.to_s
      params[:issue][:old_status] = temp.issue.status_id
      temp.issue.update_status(params[:issue][:status_id])
    end
    temp.issue.story_points = params[:item][:points].to_f if params[:item][:points]
    handler = Delayed::Job.enqueue(ItemProcessJob.new(params), 1)
    set_hash(@hash << handler.id)
    render :partial => "item", :locals => { :item => temp } 
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
