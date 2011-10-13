include ItemsHelper

class BacklogsController < ApplicationController
  unloadable
  before_filter :find_backlog, :only => [:show, :update]
  before_filter :find_project, :authorize
      
  def index
    @items         = Item.find_by_project(@project).select {|i| !i.child? }
    @item_template = Item.new
    @backlogs      = Backlog.find_by_project(@project, (params[:show_accepted_backlogs] ? nil : 3))
    @product_backlog = Backlog.find_product_backlog(@project)
    @backlog = Backlog.find(params[:backlog]) if params[:backlog]
    #@hide_closed_backlogs = cookies[:hide_closed_backlogs]=="true"
    @show_accepted_backlogs = params[:show_accepted_backlogs] ? params[:show_accepted_backlogs] : false
    @back = url_for(:controller => 'backlogs', :action => 'index')
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
    @project = if !params[:project_id].nil?
                 Project.find(params[:project_id])
               else
                 Backlog.find(params[:id]).version.project
               end
  end
  
  def find_backlog
    @backlog = if params[:id]=='0' || params[:id].nil?
                 nil
               else
                 Backlog.find(params[:id])
               end
  end
end
