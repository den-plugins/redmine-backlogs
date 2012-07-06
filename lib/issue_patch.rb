require_dependency 'issue'

module Backlogs 
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
 
      base.send(:include, InstanceMethods)
 
      base.class_eval do
        unloadable
        after_save    :update_item
        after_destroy :remove_item
      end 
    end
  
    module ClassMethods
    
    end
  
    module InstanceMethods      
      def update_item
        self.reload
        Item.update_from_issue(self)
      end
      
      def remove_item
        Item.remove_with_issue(self)
      end
      
      def update_status(id)
        self.status = IssueStatus.find(id)
        self.save
      end

      def story_points
        pts = custom_values.detect{|x| x.custom_field.name.downcase["story points"]}
        pts ? pts.value.to_f : 0.0
      end

      def story_points=(val)
        pts = custom_values.detect{|x| x.custom_field.name.downcase["story points"]}
        if !pts
          sp = CustomField.find_by_name("Story Points")
          self.attributes = {"custom_field_values"=>{"#{sp.id}"=>"#{val.to_f}"}}
          self.save
        else
          pts.value = val.to_f
          pts.save
        end
      end
    end  
  end
end
