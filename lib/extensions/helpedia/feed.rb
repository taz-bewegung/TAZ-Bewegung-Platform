module Helpedia
  module Feed #:nodoc:

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      feed_options ||= {}

      def record_feeds_of(actor, options = {})
        include_scribe_instance_methods {
          has_many :feeds, :as => :item, :dependent => :destroy
          after_create do |record|
            unless options[:if].kind_of?(Proc) and not options[:if].call(record)
              record.create_feed_from_self 
            end
          end
        }
        self.feed_options.merge! :actor => actor
      end

      def record_feeds(actions = [])
        include_scribe_instance_methods {
          has_many :feeds
          has_many :feeds_without_model, :class_name => "Feed", :conditions => { :item_type => nil, :item_id => nil }
        }
        self.feed_options.merge! :actions => actions
      end
      
      def include_scribe_instance_methods(&block)
        unless included_modules.include? InstanceMethods
          yield if block_given?
          class_inheritable_accessor :feed_options
          self.activity_options ||= {}
          include InstanceMethods
        end
      end
      
    end

    module InstanceMethods

      def create_feed_from_self
        feed = Feed.new
        feed.item = self
        feed.action = ActiveSupport::Inflector::underscore(self.class)
        actor_id = self.send( activity_options[:actor].to_s + "_id" )
        feed.user_id = actor_id
        feed.save
      end

      def record_activity(action)
        if activity_options[:actions] && activity_options[:actions].include?(action)
          feed = Feed.new
          feed.action = action.to_s
          feed.user_id = self.id
          feed.save!
        else
          raise "The action #{action} can't be tracked."
        end
      end    
    end
 
  end
end

ActiveRecord::Base.send :include, Helpedia::Feed 