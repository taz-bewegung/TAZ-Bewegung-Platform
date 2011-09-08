class LocationsController < ApplicationController

  include ImageHelper 
  include GoogleMapsHelper  

  before_filter :setup                                                
  before_filter :setup_params, :include_gm_header, :only => [:index]    
  before_filter :find_location, :only => [:show, :update, :edit, :description]  
  
  before_filter :create_brain_buster, :only => [:description]  
  
  def index
    index_for_organisation unless params[:organisation_id].blank?
    index_for_user         unless params[:user_id].blank?
    
    # Otherwise we are in the default index action
    unless params.has_keys?(:organisation_id, :event_id, :user_id)
      index_for_categories  
    end    
  end  
  
  def show
    redirect_to description_location_path(@location)
    #render :partial => "/locations/show/show", 
    #                   :layout => true, 
    #                   :locals => { :content_partial => "/locations/show/overview" }
  end 
  
  def description
    @comment = Comment.new
    @commentable_item = @location
        
    render :partial => "/locations/show/show", 
                       :layout => true, 
                       :locals => { :content_partial => "/locations/show/description" }
  end 
  
  private
  
    ###
    # Rendering for various "index" actions (organiation/user)´

    ###
    # Rendering for various "index" actions (organiation/user)´
    ### 

    def index_for_organisation   
      @organisation = Organisation.find_by_permalink(params[:organisation_id])
      raise Helpedia::ItemNotVisible unless @organisation.visible_for?(current_user)
      @locations = @organisation.locations.active
      build_map(@locations, :width => 625, :height => 400) if params[:list_type] == "maps"
      render_index_for("organisations", "Events für unsere Organisation")      
    end

    def index_for_user
      @user = User.find_by_permalink(params[:user_id])
      raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)            
      @locations = @user.locations.active
      build_map(@locations, :width => 625, :height => 400) if params[:list_type] == "maps"
      render_index_for("users", "Meine eingetragenen Events")      
    end  

    def render_index_for(type, list_title)
      respond_to do |format|
         format.html do
           render :partial => "/#{type}/show/show", :layout => true, 
                                                    :locals => { :content_partial => "/locations/index/#{type}/show" }
         end    
         format.js do
           render :update do |page|

             page["sub-content-list"].replace_html :partial => "/locations/index/shared/list_#{params[:list_type]}", 
                                                   :locals => { :locations => @locations,
                                                                :list_title => list_title
                                                              }
             unless @map.blank?                                                   
               page.insert_html("after","sub-content-list", @map.to_html(:no_load => true, :no_script => true))
             end                                                                           
           end
         end
      end      
    end    
    
    
    def index_for_categories
      conditions = ['locations.state = "active"']      
            
      if (params[:i_search]) then
          i_search = ISearch.new(params[:i_search])
          conditions = i_search.get_conditions
      end
      
      conditions.add_condition ["((location_category_memberships.location_category_id = ?))", params[:location_category_id]] unless params[:location_category_id].blank?
      
      
      alternate_locations = Location.paginate(:page => params[:page], 
                                     :order => order,
                                     :conditions => conditions,
                                     :per_page => 20,
                                     :include => [:image, :address, :location_category_memberships]) if params[:list_type] == "maps"
      
      @locations = Location.paginate(:page => params[:page], 
                                     :order => order,
                                     :conditions => conditions,
                                     :per_page => @per_page,
                                     :include => [:image, :address, :location_category_memberships])
      
      @locations.update_total_pages(alternate_locations.total_pages) if params[:list_type] == "maps"
      
      build_map(@locations, :width => 660, :height => 400, :max_visible_markers => 500) if params[:list_type] == "maps"
      @cache_key = cache_key
      respond_to do |format|
        format.html do
          render :partial => "/locations/index", :layout => true
        end    
        format.js do
          render :action => :index
        end
        format.xml
      end
    end
    
    def setup_params
      params[:order] = "newest" if params[:order].blank?          
      params[:list_type] = 'maps' if params[:list_type].blank?
      @per_page = if params[:list_type] == "maps" then 10000 else 20 end
      params[:page] = 1 if params[:page].blank? or params[:list_type] == "maps"
    end
    
    def find_location
      @location = Location.find_by_permalink(params[:id])
      raise ActiveRecord::RecordNotFound if @location.blank? 
      raise Helpedia::ItemNotVisible unless @location.visible_for?(current_user)
    end
    
    def setup
      @template.main_menu :locations
    end

    def order
      case params[:order]
        when "title"                     then "locations.name ASC"
        when "newest"                    then "locations.created_at DESC"
        when "last_update"               then "locations.updated_at DESC"
        when "random"                    then "rand()"
        when nil                         then 'locations.created_at DESC'
      end
    end 
      
end
