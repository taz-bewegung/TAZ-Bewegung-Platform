module Helpedia
  module SslRequirement
    def self.included(controller)
      controller.extend(ClassMethods)
      controller.before_filter(:ensure_proper_protocol)
    end

    module ClassMethods
      # Specifies that the named actions requires an SSL connection to be performed (which is enforced by ensure_proper_protocol).
      def ssl_required(*actions)
        write_inheritable_array(:ssl_required_actions, actions)
      end

      def ssl_allowed(*actions)
        write_inheritable_array(:ssl_allowed_actions, actions)
      end
    end
  
    protected
      # Returns true if the current action is supposed to run as SSL
      def ssl_required?
        (self.class.read_inheritable_attribute(:ssl_required_actions) || []).include?(action_name.to_sym)
      end
    
      def ssl_allowed?
        (self.class.read_inheritable_attribute(:ssl_allowed_actions) || []).include?(action_name.to_sym)
      end

    private
      def ensure_proper_protocol
      
        # If we should use only ssl
        if application.ssl_only == true
          unless request.ssl? 
            redirect_to "https://" + request.host + request.request_uri
            flash.keep      
          end
          return false        
        end
        
        
        if ENV['RAILS_ENV'] == 'production'
          return true if ssl_allowed?

          if ssl_required? && !request.ssl?
            redirect_to "https://" + request.host + request.request_uri
            flash.keep
            return false
          elsif request.ssl? && !ssl_required?
            redirect_to "http://" + request.host + request.request_uri
            flash.keep
            return false
          end
        end
      end
  end
end