require "uuidtools"
module Bewegung
  module Uuid
    def self.included(base)
      base.class_eval do

        # Include helper
        include UuidHelper

        # Set Primary Key
        set_primary_key :uuid

        before_create :set_uuid
      end
    end

    module UuidHelper
      def set_uuid
        self.uuid = UUIDTools::UUID.timestamp_create().to_s
      end

    end
  end
end
ActiveRecord::Base.send :include, Bewegung::Uuid