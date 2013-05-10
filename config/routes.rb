if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    match 'projects/:project_id/backlogs', :to => 'backlogs#index'
    resources :backlogs, :shallow => true do
      resources :items do
        resources :tasks, :comments
      end

      resource :chart
    end

    resources :items, :tasks
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.connect 'projects/:project_id/backlogs', :controller => 'backlogs', :action => 'index'

    map.resources :backlogs, :shallow => true do |backlog|
      backlog.resources :items do |item|
        item.resources :tasks
        item.resources :comments
      end
      
      backlog.resource :chart
    end

    map.resources :items
    map.resources :tasks
  end
end
