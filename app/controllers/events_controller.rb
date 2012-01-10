# encoding: UTF-8
class EventsController < ApplicationController

  include ImageHelper
  include GoogleMapsHelper
  
  before_filter :setup
  before_filter :find_event, :only => [:show]
  before_filter :setup_params, :include_gm_header, :only => [:index, :map, :iframe_map]  

  def index
    index_for_user          unless params[:user_id].blank?
    index_for_organisation  unless params[:organisation_id].blank? 
    index_for_activity      unless params[:activity_id].blank?
    index_for_location      unless params[:location_id].blank?
    unless params.has_keys?(:user_id, :organisation_id, :activity_id, :location_id)
      index_for_categories
    end
  end
  
  def index_for_categories
    conditions = ['events.state = "active"']
    
    if (params[:i_search]) then
      i_search = ISearch.new(params[:i_search])
      conditions = i_search.get_conditions
    end
    
    # If we are in calendar view, look for all events in a month
    if params[:list_type] == "cal"
      conditions.add_condition ["events.starts_at < ?", params[:date].to_date.end_of_month]
      conditions.add_condition ["events.ends_at > ?", params[:date].to_date.beginning_of_month]
    elsif %w( tiny rows cards ).include?(params[:list_type]) and not (params[:i_search].present? and params[:i_search][:from_date].present?)
      conditions.add_condition ["events.ends_at >= ?", Date.today.beginning_of_day]
      conditions.add_condition ["days_with_events.day >= ?", Date.today.beginning_of_day-2.hours]
    else
      #conditions.add_condition ["events.ends_at > ?", Date.today.beginning_of_day]
    end
    
    if request.format != :xml
      
      @events = Event.paginate(:page => params[:page], 
                              :order => order,
                              :conditions => conditions,
                              :include => [:address, :social_category_memberships, :days_with_events],
                              :per_page => @per_page) if not %w( tiny rows cards ).include?(params[:list_type]) or params[:order] != "starts_at"  
      
      @events = DaysWithEvent.paginate(:page => params[:page], 
                              :order => "days_with_events.day",
                              :conditions => conditions,
                              #:joins => "INNER JOIN events on days_with_events.event_id = events.uuid",
                              :include => [:event => [:address, :social_category_memberships] ],
                              :per_page => @per_page) if %w( tiny rows cards ).include?(params[:list_type]) and params[:order] == "starts_at"

      if %w( tiny rows cards ).include?(params[:list_type]) and params[:order] == "starts_at"
        @grouped_events = @events.group_by { |g| I18n.l(g.day.to_date, :format => "%d. %B %Y") } 
      end

      build_map(@events, :width => 660, :height => 400) if params[:list_type] == "maps"
    end
    
    respond_to do |format|
      format.html { render :partial => "/events/index", :layout => true }
      format.js { }      
      format.xml do
        if params[:i_search].present?
          rss_condition = i_search.get_conditions
          @events = Event.paginate(:page => params[:page], 
                                  :order => order,
                                  :conditions => rss_condition,
                                  :include => [:address, :social_category_memberships, :days_with_events],
                                  :order => "days_with_events.day",
                                  :per_page => @per_page)
        else
          @events = Event.find(:all, :limit => 20, :order => "starts_at ASC", :conditions => ["starts_at>=now()"]) 
        end
      end
    end
  end


  def show  
    respond_to do |format|
      format.html { render_partial_for_html("/events/show/description") }
      format.js { render_partial_for_js("/events/show/description") }
      format.ics { render :text => @event.to_ical }
    end    
  end  
  
  
  def for_day
    day = params[:day].to_time
    @events = Event.find :all, :conditions => ["starts_at < ? AND ends_at > ?", day.end_of_day.to_s(:db), day.beginning_of_day.to_s(:db)]
    render :update do |page|
      page["day-events"].replace_html :partial => "/events/index/shared/list_cal_items", 
                                      :locals => { :events => @events }
    end
  end
  
  def iframe_map
    @activity = Activity.find_by_permalink(params[:activity_id])
    raise Helpedia::ItemNotVisible unless @activity.visible_for?(current_user)
    @events = @activity.events.active.all(:order => "starts_at DESC", :conditions => ["starts_at >= ?", Time.now.beginning_of_day.to_s(:db)])
    build_map(@events, :width => 625, :height => 400) 
    render "/events/index/activities/iframe_map", :layout => "iframe_map"
  end
  
  def map
    @activity = Activity.find_by_permalink(params[:activity_id])
    raise Helpedia::ItemNotVisible unless @activity.visible_for?(current_user)
    @events = @activity.events.active.all(:order => "starts_at DESC", :conditions => ["starts_at >= ?", Time.now.beginning_of_day.to_s(:db)])
    build_map(@events, :width => 625, :height => 400) 
    render :partial => "/activities/show/show", :layout => true, 
                                                :locals => { :content_partial => "/events/index/activities/map", 
                                                :sub_menu_active => :events_map }
    
  end
  
  private
  
  ###
  # Rendering for various "index" actions (organiation/user)´
  ### 
  
  def index_for_organisation   
    @organisation = Organisation.find_by_permalink(params[:organisation_id])
    raise Helpedia::ItemNotVisible unless @organisation.visible_for?(current_user)
    @events = @organisation.committed_events.active.all(:order => "starts_at DESC")
    build_map(@events, :width => 625, :height => 400) if params[:list_type] == "maps"
    render_index_for("organisations", "Termine für unsere Organisation")      
  end
  
  def index_for_location
    @location = Location.find_by_permalink(params[:location_id])
    raise Helpedia::ItemNotVisible unless @location.visible_for?(current_user)
    @events = @location.events.running.all(:order => "starts_at DESC")
    build_map(@events, :width => 625, :height => 400) if params[:list_type] == "maps"
    render_index_for("locations", "Termine für unseren Ort")      
  end
  
  def index_for_user
    @user = User.find_by_permalink(params[:user_id])
    raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)
    @events = @user.events.active.all(:order => "starts_at DESC")
    build_map(@events, :width => 625, :height => 400) if params[:list_type] == "maps"
    render_index_for("users", "Meine eingetragenen Termine")      
  end
  
  def index_for_activity
    @activity = Activity.find_by_permalink(params[:activity_id])
    raise Helpedia::ItemNotVisible unless @activity.visible_for?(current_user)
    if params[:list_type] == "maps"
      @events = @activity.events.active.running.upcoming.all(:order => "starts_at DESC")
      build_map(@events, :width => 625, :height => 400)
    else
      @events = @activity.events.active.all(:order => "starts_at DESC")
    end
    render_index_for("activities", "Meine eingetragenen Termine", :events)
  end

  
  def render_index_for(type, list_title, submenu = nil)
    respond_to do |format|
       format.html do
         render :partial => "/#{type}/show/show", :layout => true, 
                                                  :locals => { :content_partial => "/events/index/#{type}/show", :sub_menu_active => submenu }
       end    
       format.js do
         render :update do |page|
           
           page["sub-content-list"].replace_html :partial => "/events/index/shared/list_#{params[:list_type]}", 
                                                 :locals => { :events => @events,
                                                              :list_title => list_title
                                                            }
           unless @map.blank?                                                   
             page.insert_html("after","sub-content-list", @map.to_html(:no_load => true, :no_script => true))
           end                                                                           
         end
       end
    end      
  end
  
  ###
  # "Show" action rendering
  ##
   
   
   def render_partial_for_html(partial)
      render :partial => "/events/show/show", 
                         :layout => true, 
                         :locals => { :content_partial => partial }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end    
    end 
        
    def setup_params
      params[:order] ||= 'starts_at'
      
      unless params.has_keys?(:user_id, :organisation_id, :activity_id, :location_id)
        params[:list_type] ||= 'tiny'
      else
        params[:list_type] ||= 'rows'
      end

      params[:event] = {} if params[:event].blank?
      @per_page = case 
                  when %w(maps cal).include?(params[:list_type]) then 2_000
                  when %w(tiny).include?(params[:list_type]) then 40
                  else
                    Event::PER_PAGE[:overview_list]
                  end
      params[:page] = if %w(maps cal).include?(params[:list_type]) then 1 else params[:page] end
      params[:page] = 1 if params[:pagination_reload] == "1" or params[:page].blank?
      params[:date] = Date.today.to_s if %w(cal).include?(params[:list_type]) and params[:date].blank?
    end     
  
    def setup
      #view_context.main_menu :events
      @current_main_menu_id = :events
    end
    
    def find_event
      @event = Event.find_by_permalink(params[:id], :include => :originator)
      raise ActiveRecord::RecordNotFound if @event.blank?             
      raise Helpedia::ItemNotVisible unless @event.visible_for?(current_user)
    end
    
    def order
      case params[:order]
        when "title"                     then "events.title ASC"
        when "created_at"                then "events.created_at DESC"
        when "starts_at"                 then "events.starts_at ASC"
        when nil                         then 'events.starts_at ASC'
      end
    end 
    
end
