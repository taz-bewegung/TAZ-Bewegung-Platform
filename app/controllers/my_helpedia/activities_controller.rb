class MyHelpedia::ActivitiesController < ApplicationController
  
  include ImageHelper

  before_filter :find_activity, :only => [:show, :update, :edit, :update, :description, :edit_part, :cancel_edit_part, :destroy, :destroy_confirmation]
  before_filter :setup
  before_filter :setup_params, :include_gm_header, :only => [:index]
  before_filter :login_required
  
  before_filter :restrict_access, :only => [:new, :create]
  
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :edit_part, :destroy_confirmation, :destroy
  
  uses_tiny_mce :only => [:edit, :new, :create], :options => TAZ_TINY_MCE_OPTIONS
  
  def index 
    @template.use_googlemaps        
    index_for_user                 if current_user.is_a?(User)
    index_for_organisation         if current_user.is_a?(Organisation)
  end
  
  def new
    @activity = Activity.new(params[:activity])
    @activity.end_date = I18n.l(Date.today + 1.year, :format => "%d.%m.%Y")
  end
  
  def create
    @activity = Activity.new(params[:activity])
    @activity.owner = current_user

    if @activity.save
      if params[:image]
        @activity.image = Image.find(params[:image])
      end    
      redirect_to edit_my_helpedia_activity_path(@activity)
    else
      if params[:image]
        @activity.temp_image = Image.find(params[:image])
      end      
      render :action => "new"
    end
  end

  
  def edit
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/activities/edit/edit") } 
      format.js { render_partial_for_js("/my_helpedia/activities/edit/edit") }       
    end
  end 

  def show 
    flash.keep
    redirect_to edit_my_helpedia_activity_path(@activity)
    #respond_to do |format|
    #  format.html { render_partial_for_html("/my_helpedia/activities/show/overview") } 
    #  format.js { render_partial_for_js("/my_helpedia/activities/show/overview") }       
    #end    
  end
  
  def description
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/activities/show/description") } 
      format.js { render_partial_for_js("/my_helpedia/activities/show/description") }       
    end    
  end


  def update
    # Save the address if delivered
    unless params[:address].blank?
      @activity.address.attributes = params[:address] 
      @activity.address.save_with_validation(false)
    end         
    
    # Save image if delivered
    unless params[:image].blank?
      @activity.image = Image.find(params[:image])
    end  
    
     fields = case params[:part]
              when "activity_texts" then [:goal, :description, :problem, :code]
              else
                [:permalink, :title, :description, :end_date]
              end
      
    @activity.attributes = params[:activity]
    if @activity.validate_attributes(:only => fields)    
      @activity.save(false)
      @activity.reload
      render :update do |page|
        page[params['part']].replace :partial => "/my_helpedia/activities/edit/#{params['part']}"
      end    
    else
      render :update do |page|
        page[params['part']].replace :partial => "/my_helpedia/activities/edit/edit_#{params['part']}"
        page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
      end      
    end
  end
    
  def cancel_edit_part
    render :update do |page|
      page[params['part']].replace :partial => "/my_helpedia/activities/edit/#{params['part']}"
    end
  end
  
  def edit_part
    render :update do |page|
      page[params['part']].replace :partial => "/my_helpedia/activities/edit/edit_#{params['part']}"
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
    end    
  end
  
  def destroy_confirmation
  end
  
  def destroy
    @activity.destroy
    render :update do |page|
      page << "window.location.href='#{my_helpedia_url}'" 
    end
  end 
 
  private
  
    ###
    # Rendering for various "index" actions (organiation/user)´
    ### 
  
    def index_for_event
      @event = Event.find_by_permalink(params[:event_id])
      @activities = @event.activities
      extend GoogleMapsHelper
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"            
      render_index_for("events", t(:"event.public_profile.sub_content.tabs.activities.content.list_title"))
    end
    
    def index_for_user
      @user = current_user
      @activities = @user.activities
      extend GoogleMapsHelper
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"            
      render_index_for("users", t(:"user.public_profile.sub_content.tabs.activities.content.list_title"))      
    end
    
    def index_for_organisation
      @organisation = current_user
      @activities = @organisation.activities
      extend GoogleMapsHelper
      build_map(@activities, :width => 625, :height => 400) if params[:list_type] == "maps"            
      render_index_for("organisations", "Aktionen für unsere Organisation")      
    end
    
    def render_index_for(type, list_title = nil)
      respond_to do |format|
         format.html do
           render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                                :locals => { :content_partial => "/my_helpedia/activities/index/show" }
         end    
         format.js do
           render :update do |page|
             page["sub-content-list"].replace_html :partial => "/my_helpedia/activities/index/list_#{params[:list_type]}", 
                                              :locals => { :activities => @activities,
                                                           :list_title => list_title }   
             page.insert_html("after","sub-content",@map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
           end
         end
      end      
    end  
        
    def setup_params
      params[:filter] = { :running => "1", :waiting => "1", :finished => "1" } if params[:filter].blank?    
      params[:list_type] = 'cards' if params[:list_type].blank?
    end
    
    ###
    # "Show" action rendering
    ##

    def render_partial_for_html(partial)
      render :partial => "/my_helpedia/activities/show/show", 
                         :layout => true, 
                         :locals => { :content_partial => partial }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end
    end
    
    def restrict_access
      raise Helpedia::ItemNotVisible unless current_user.active?
    end
  
    def find_activity
      @user = current_user
      @activity = @user.activities.find_by_permalink(params[:id])
    end
  
    def setup
      @template.main_menu :my_helpedia  
    end
  
end
