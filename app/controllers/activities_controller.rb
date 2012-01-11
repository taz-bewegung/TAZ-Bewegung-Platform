# encoding: UTF-8
class ActivitiesController < ApplicationController
  
  include ImageHelper 
  include GoogleMapsHelper
  
  before_filter :setup                                                
  before_filter :setup_params, :include_gm_header, :only => [:index]
  before_filter :find_activity, :only => [:show, :update, :edit, :description]  
  
  before_filter :create_brain_buster, :only => [:description]
  #caches_action :index,  :expires_in => 300.seconds, :format => :xml
  
  def index   
    index_for_event        unless params[:event_id].blank?
    index_for_organisation unless params[:organisation_id].blank?
    index_for_user         unless params[:user_id].blank?
      
    # Otherwise we are in the default index action
    unless params.has_keys?(:organisation_id, :event_id, :user_id)
      index_for_categories
    end
    
  end 
  
  def show    
    respond_to do |format|
      format.html { redirect_to description_activity_path } 
      format.js { render_partial_for_js("/activities/show/overview", :overview) }
      format.ics { render :text => @activity.to_ical }
    end    
  end
  
  def description
    @comment = Comment.new
    @commentable_item = @activity
    
    respond_to do |format|
      format.html { render_partial_for_html("/activities/show/description", :description) }
      format.js { render_partial_for_js("/activities/show/description", :description ) }
    end    
  end
  
  def for_day
    day = params[:day].to_time
    @activities = Activity.find :all, :conditions => ["starts_at <= ? AND ends_at >= ?", day.end_of_day.to_s(:db), day.beginning_of_day.to_s(:db)]
    render :update do |page|
      page["day-events"].replace_html :partial => "/activities/index/shared/list_cal_items", 
                                      :locals => { :activities => @activities }
    end    
  end  
  
  
 # def rss
 #   conditions = ['activities.state = "active"']
 #   conditions.add_condition ["(activities.ends_at > ? or activities.continuous = 1)", Time.now]
 #   @activities = Activity.paginate(:page => params[:page], 
 #                                   :order => order,
 #                                   :conditions => conditions,
 #                                   :per_page => @per_page,
 #                                   :include => [:image, :address, :social_category_memberships])
 #   
 # end
  
  private  
    
    ###
    # Rendering for various "index" actions (organiation/user)´

    def index_for_categories

      conditions = ['activities.state = "active"']
      if (params[:i_search]) then
        i_search = ISearch.new(params[:i_search])
        conditions = i_search.get_conditions
      end
       
      conditions.add_condition ["(activities.ends_at > ? or activities.continuous = 1)", Time.now]
      @cache_key = cache_key
      #@activities = Rails.cache.fetch("db-query-#{@cache_key}", :expires_in => 5.minutes) do
      #  Activity.paginate(:page => params[:page], 
      #                    :order => order,
      #                    :conditions => conditions,
      #                    :per_page => @per_page,
      #                    :include => [:image, :address, :social_category_memberships])
      #  end
      #
      @activities = Activity.paginate(:page => params[:page], 
                                       :order => order,
                                       :conditions => conditions,
                                       :per_page => @per_page,
                                       :include => [:image, :address, :social_category_memberships])
                            
       
      build_map(@activities, :width => 660, :height => 400) if params[:list_type] == "maps"       
      
    respond_to do |format|
      format.html do
        render "/activities/_index", :layout => true
      end    
      format.js do
        render :action => :index
      end
      format.xml
    end    
  end

    
    def add_googlemaps      
      view_context.use_googlemaps
    end
    
    def index_for_event
      @event = Event.find_by_permalink(params[:id], :include => :originator)
      raise Helpedia::ItemNotVisible unless @event.visible_for?(current_user)      
      @activities = @event.activities.active.all(:include => [:image, :address]) 
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"            
      render_index_for("events", t(:"event.public_profile.sub_content.tabs.activities.content.list_title"))
    end
    
    def index_for_user
      @user = User.find_by_permalink(params[:user_id])
      raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)            
      @activities = @user.activities.active.all(:include => [:image, :address])
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"      
      render_index_for("users", t(:"user.public_profile.sub_content.tabs.activities.content.list_title"))      
    end
    
    def index_for_organisation
      @organisation = Organisation.find_by_permalink(params[:organisation_id])
      raise Helpedia::ItemNotVisible unless @organisation.visible_for?(current_user)            
      @activities = @organisation.activities.active.all(:include => [:image, :address])
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"
      render_index_for("organisations", "Aktionen für unsere Organisation")
      return false
    end
    
    def render_index_for(type, title = nil)
      respond_to do |format|
         format.html do
           render :partial => "/#{type}/show/show", :layout => true, 
                                                    :locals => { :content_partial => "/activities/index/#{type}/show" }
         end    
         format.js do
           render :update do |page|
             page["sub-content-list"].replace_html :partial => "/activities/index/shared/list_#{params[:list_type]}", 
                                                   :locals => { :activities => @activities,
                                                                :list_title => title}
              unless @map.blank?                                                   
                page.insert_html("after","sub-content-list", @map.to_html(:no_load => true, :no_script => true))
              end                                                                   
           end
         end
      end      
    end  
    
    def setup_params
      params[:order] = "newest" if params[:order].blank?          
      params[:list_type] = 'cards' if params[:list_type].blank?
      @per_page = if %w(maps cal).include?(params[:list_type]) then 1_000 else 20 end
      params[:page] = if %w(maps cal).include?(params[:list_type]) then 1 else params[:page] end
      params[:date] = Date.today.to_s if %w(cal).include?(params[:list_type]) and params[:date].blank?      
      params[:page] = 1 if params[:pagination_reload] == "1" or params[:page].blank?      
    end
    
    ###
    # "Show" action rendering
    ##
    def render_partial_for_html(partial, sub_menu_active)
      render :partial => "/activities/show/show", 
                         :layout => true, 
                         :locals => { :content_partial => partial, :sub_menu_active => sub_menu_active }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end    
    end 
  
    
    # Finds an activity from the params. Also deals with legacy elargio URLs.
    def find_activity
      @activity = Activity.find_by_permalink(params[:id])
      raise ActiveRecord::RecordNotFound if @activity.blank?       
      raise Helpedia::ItemNotVisible unless @activity.visible_for?(current_user)
      @user = @activity.owner
    end

    
    def setup
      view_context.main_menu :activities  
    end

    def order
      case params[:order]
        when "title"                     then "activities.title ASC"
        when "starts_at"                 then "activities.starts_at ASC"
        when "ends_at"                   then "activities.ends_at DESC"
        when "last_update"               then "activities.updated_at DESC"
        when "newest"                    then "activities.created_at DESC"
        when "random"                    then "rand()"
        when nil                         then 'activities.starts_at ASC'       
      end
    end 
  
end
