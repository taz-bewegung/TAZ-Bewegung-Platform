# encoding: UTF-8
=begin rapidoc
  name:: Themen-Kategorien
  json:: <%= CodeRay.encode(SocialCategory.first.api_hash.to_json, :json, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>
  xml:: <%= CodeRay.encode(SocialCategory.first.api_hash.to_xml(:root => :social_category), :xml, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>

  Über die API für Kategorien können die Kategorien auf bewegung.taz.de in verschiedenen Formaten exportiert werden.
    
=end

class Api::V1::SocialCategoriesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  #before_filter :authenticate

=begin rapidoc
  name:: Themen-Kategorien auslesen
  url:: /api/v1/themen_kategorien
  method:: GET
  access:: Authorisierung erforderlich
  param:: page :: integer :: Optional :: Die aktuelle Seite
  param:: per_page :: integer :: Optional :: Wie viele Kategorien sollen pro Seite angezeigt werden
  formats:: xml, json
  return:: Eine Liste mit Kategorien
  return_xml:: <%= CodeRay.encode(render(:partial => \"/api/v1/social_categories/index.xml.builder\", :locals => { :social_categories => SocialCategory.paginate(:page => 1, :per_page => 2) }), :xml, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>
  return_json:: <%= CodeRay.encode(SocialCategory.paginate(:page => 1, :per_page => 2).to_json, :json, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>  
  
  samples:: curl <%= application.site_url %>/api/v1/themen_kategorien.xml?page=1&per_page=5

  Liefert eine Liste mit Kategorien zurück. Die Liste ist abhängig von den gewählten Parametern und dem gewählten Format.<br />
=end  
  def index
    @social_categories = SocialCategory.paginate(:page => params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.json { render :json => @social_categories }
      format.xml { render :partial => "index", :locals => { :social_categories => @social_categories } }
    end
  end
  
  private
        
    # Authenticates a user
    def authenticate
      
      # Try to find by api_key first
      if params[:api_key].present?
        self.current_user = Organisation.find_by_apikey(key)
        return true
      end
      
      # Or we login via http_basic
      authenticate_or_request_with_http_basic do |username, password| 
        user = User.authenticate(username, password)
        user = Organisation.authenticate(username, password) if user.nil?
        if user
          self.current_user = user
          return true
        else
          return false
        end
      end
    end  
    
end
