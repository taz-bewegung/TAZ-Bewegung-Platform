module ActiveRecord  
  module Validations  
    module ClassMethods  
   
      def validates_overall_uniqueness_of(*attr_names)
        configuration = { :case_sensitive => false }
        configuration.update(attr_names.extract_options!)
      
        validates_each(attr_names,configuration) do |record, attr_name, value|

          user_with_email = User.exists?(["uuid != ? AND email = ?", record.id.to_s, value])
          organisation_with_email = Organisation.exists?(["uuid != ? AND contact_email = ?", record.id.to_s, value])
          record.errors.add(attr_name, :taken, :default => configuration[:message], :value => value) if user_with_email or organisation_with_email
         
        end
      end
      
      
    end  
  end  
end


# Make notify public that we can use it outside the model.
module ActiveRecord
  class Base
    def notify_observers(method)
      notify(method)
    end
    
    def touch!
      self.update_attribute(:updated_at, Time.now) if self.respond_to? :updated_at
    end
  end
end
