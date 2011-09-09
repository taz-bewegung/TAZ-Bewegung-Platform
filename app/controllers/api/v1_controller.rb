# encoding: UTF-8
class Api::V1Controller < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate
  before_filter :setup_params, :only => [:index]
  
  rescue_from Helpedia::InvalidApiAuthentication, :with => :invalid_key
    
  protected
  
    def setup_params
      params[:per_page] = 20 if params[:per_page].blank?
      params[:page] = 1 if params[:page].blank?      
    end
        
    # Authenticates a user
    def authenticate
      
      # Try to find by api_key first
      if params[:api_key].present?
        self.current_user = Organisation.find_by_api_key(params[:api_key])
      end
      
      # Or we login via http_basic
      #authenticate_or_request_with_http_basic do |username, password| 
      #  user = User.authenticate(username, password)
      #  user = Organisation.authenticate(username, password) if user.nil?
      #  if user
      #    self.current_user = user
      #  else
      #    raise Helpedia::InvalidApiAuthentication if self.current_user.blank?
      #    return false
      #  end
      #end
      
      if self.current_user.blank?
        raise Helpedia::InvalidApiAuthentication 
        return false
      end
    end
    
    protected
    
      def invalid_key
        respond_to do |type|
          type.xml { render :partial => "errors/access_denied.xml.builder", :status => 401 }
        end
      end
  
end
