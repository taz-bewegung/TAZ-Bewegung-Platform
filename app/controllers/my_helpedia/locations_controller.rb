class MyHelpedia::LocationsController < ApplicationController

  include ImageHelper 
  include GoogleMapsHelper

  before_filter :login_required
  before_filter :find_location, :only => [:show, :update, :edit, :update, :description, :edit_part, :cancel_edit_part, :extend, :destroy, :destroy_confirmation]  
  before_filter :setup
  before_filter :setup_params, :include_gm_header, :only => [:index]
  
  before_filter :restrict_access, :only => [:new, :create]  
  
  uses_tiny_mce :only => [:edit, :new, :create], :options => TAZ_TINY_MCE_OPTIONS
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :edit_part, :destroy, :destroy_confirmation
  ssl_allowed :list
  
  # Renders the form for a new location.
  def new
    @location = Location.new(params[:location])
    @location.address = Address.new
  end
  
  def list
     locations = Location.find :all, :conditions => [ "LOWER(name) LIKE ?", 
                                                      '%'+params[:q].to_s.downcase + '%'],
                               :order => "name ASC",
                               :limit => 10
     render :json => locations.map{ |location| { :value => location.id, :label => location.name} }
   end
  
  
  def destroy
    @location.destroy
    render :update do |page|
      page << "window.location.href='#{my_helpedia_url}'" 
    end
  end
  
  
  # Creates a new location.
  def create
    @location = Location.new(params[:location])
    @location.owner = current_user
    
    # FIXME Shoud go into model
    # Validate individual
    valid_location = @location.validate_attributes(:only => [:name, :permalink, :description, :email])
    @location.address.errors.clear
    valid_address = @location.address.validate_attributes(:only => [:street,:zip_code,:city])
    
    if valid_address and valid_location
      @location.save
      @location.image = Image.find(params[:image]) if params[:image]
      redirect_to my_helpedia_location_path(@location)
    else
      @location.temp_image = Image.find(params[:image]) if params[:image]
      render :action => "new"
    end    
  end  
  
  def index 
    @template.use_googlemaps              
    index_for_user                 if current_user.is_a?(User)
    index_for_organisation         if current_user.is_a?(Organisation)
  end  
  
  def edit
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/locations/edit/edit") } 
      format.js { render_partial_for_js("/my_helpedia/locations/edit/edit") }       
    end
  end 

  def show 
    flash.keep
    redirect_to edit_my_helpedia_location_path(@location)
    #respond_to do |format|
    #  format.html { render_partial_for_html("/my_helpedia/locations/show/overview") } 
    #  format.js { render_partial_for_js("/my_helpedia/locations/show/overview") }       
    #end    
  end
  
  
  def cancel_edit_part
    render :update do |page|
      page[params['part']].replace_html :partial => "/my_helpedia/locations/edit/#{params['part']}"
    end
  end

  def edit_part
    render :update do |page|
      page[params['part']].replace_html :partial => "/my_helpedia/locations/edit/edit_#{params['part']}"
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
    end
  end 
  
  def update
    # Save the address if delivered
     unless params[:address].blank?
       @location.address.attributes = params[:address] 
       @location.address.save_with_validation(false)
     end    
     
     # Save image if delivered
     unless params[:image].blank?
       @location.image = Image.find(params[:image])
     end     
     
     # Validate the different attributes 
     fields = case params[:part]               
              when "location_data" then [:name, :permalink, :email]
              when "address" then [:name]                
              when "categories" then [:name]
              end
     
     @location.attributes = params[:location]
     if @location.validate_attributes(:only => fields)     
       
       # Finally save       
       @location.save_with_validation(false)
       
       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/locations/edit/#{params['part']}"
       end    
     else
       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/locations/edit/edit_#{params['part']}"
         page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
       end      
     end    
  end

  private 
  
    ###
    # "Index" action rendering
    ##
    
  
   def index_for_user
     @user = current_user
     @locations = @user.locations
     build_map(@locations, :width => 620, :height => 400) if params[:list_type] == "maps"            
     render_index_for("users")      
   end
   
   def index_for_organisation
     @organisation = current_user
     @locations = @organisation.locations
     build_map(@locations, :width => 620, :height => 400) if params[:list_type] == "maps"            
     render_index_for("organisations")      
   end
   
   def render_index_for(type, list_title = nil)
     respond_to do |format|
        format.html do
          render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                               :locals => { :content_partial => "/my_helpedia/locations/index/#{type}/show" }
        end    
        format.js do
          render :update do |page|
            page["sub-content-list"].replace_html :partial => "/my_helpedia/locations/index/shared/list_#{params[:list_type]}", 
                                             :locals => { :activities => @activities,
                                                          :list_title => list_title }   
            page.insert_html("after","sub-content",@map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
          end
        end
     end
   end
   
  
    ###
    # "Show" action rendering
    ##

    def render_partial_for_html(partial)
      render :partial => "/my_helpedia/locations/show/show", 
                         :layout => true, 
                         :locals => { :content_partial => partial }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end    
    end  
    
    # Sets up the parameters
    def setup_params
      params[:list_type] = 'cards' if params[:list_type].blank?
    end  
  
    def find_location
      @user = current_user
      @organisation = current_user if current_user.is_a?(Organisation)
      @location = @user.locations.find_by_permalink(params[:id])      
    end
    
    def restrict_access
      raise Helpedia::ItemNotVisible unless current_user.active?
    end    

    def setup
      @template.main_menu :my_helpedia  
    end  
  
  

end
