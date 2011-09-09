module Helpedia
  module Uuid
    
    
    def self.included(base)
      base.class_eval do
        include UUIDHelper
        #set_primary_key :uuid
        before_create :generate_uuid
        def generate_uuid
          self.uuid = UUID.timestamp_create.to_s
        end

      end
    end

    module UUIDHelper
      
      def generate_uuid
        self.uuid = UUID.timestamp_create.to_s
      end
    end

  end
end
ActiveRecord::Base.send :include, Helpedia::Uuid