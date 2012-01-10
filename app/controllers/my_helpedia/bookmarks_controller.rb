class MyHelpedia::BookmarksController < ApplicationController

  include GoogleMapsHelper 
  include ImageHelper 
  
  before_filter :login_required
  before_filter :user_login_required
  before_filter :find_user
  before_filter :setup_params, :include_gm_header, :setup
  
  ssl_required :index, :view

  def index
    @active = params[:type].to_sym
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/bookmarks/index" }
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => "/my_helpedia/bookmarks/bookmarks"
        end
      end
    end
  end
  
  def view
    @active = params[:type].to_sym
    items = current_user.send("#{params[:type].to_s.singularize}_bookmarks")
    build_map(items, :width => 620, :height => 400) if params[:list_type] == "maps"
    respond_to do |format|
       format.html do
         render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                              :locals => { :content_partial => "/my_helpedia/events/index/show" }
       end    
       format.js do
         render :update do |page|
           page["sub-content-list"].replace_html :partial => "/#{params[:type]}/index/shared/list_#{params[:list_type]}", 
                                                         :locals => { params[:type].to_sym => items,
                                                         :list_title => "taB" }   
           page.insert_html("after","sub-content", @map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
         end
       end
    end
  end
  
  private
  
    def find_user
      @user = current_user
    end
    
    def setup_params
      params[:list_type] = :cards if params[:list_type].blank?
      params[:type] = :events if params[:type].blank?
    end
  
    def setup
      view_context.main_menu :my_helpedia
    end
  
end
