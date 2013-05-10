require 'redmine'
require 'redis'
$redis = Redis.new

# Patches to the Redmine core
require 'issue_patch'
require 'version_patch'
#require 'dispatcher'
require 'weekdays'

# Including dispatcher.rb in case of Rails 2.x
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require 'issue_patch'
    require 'version_patch'
  end
else
  Dispatcher.to_prepare BW_AssetHelpers::PLUGIN_NAME do
    # use require_dependency if you plan to utilize development mode
    require 'issue_patch'
    require 'version_patch'
  end
end

Redmine::Plugin.register :redmine_backlogs do
  name 'Redmine Backlogs plugin'
  author 'Mark Maglana'
  description 'Agile/Scrum backlog management tool'
  version '0.0.1'
  
  
  project_module :backlogs do
    permission :backlogs, { :backlogs => [:index, :show, :update],
                            :charts   => [:show],
                            :comments => [:index, :create],
                            :items    => [:index, :create, :update],
                            :tasks    => [:index]                   
                          }, :public => false
  end

  menu :project_menu, 
       :backlogs, 
       { :controller => 'backlogs', :action => :index }, 
       :caption => 'Backlog Planning',
       :after   => :burndown, 
       :param   => :project_id
end
