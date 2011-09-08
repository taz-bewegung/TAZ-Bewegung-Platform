require 'rubygems'
require 'uuidtools'

module Helpedia
  module Uuid

    def self.included(receiver)
      receiver.class_eval do 
        include UUIDHelper
        set_primary_key "uuid"
      end
    end
    
    module UUIDHelper
      def before_create
        self.uuid = UUID.timestamp_create.to_s
      end
    end     
    
  end
end

ActiveRecord::Base.send :include, Helpedia::Uuid