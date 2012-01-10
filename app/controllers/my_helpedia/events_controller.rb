class MyHelpedia::EventsController < ApplicationController

  include ImageHelper 
  include GoogleMapsHelper  

  before_filter :login_required
  before_filter :find_event, :only => [:show, :update, :edit, :update, :description, :edit_part, :cancel_edit_part, :destroy_confirmation, :destroy]  
  before_filter :setup
  before_filter :setup_params, :include_gm_header, :only => [:index]
  
  before_filter :restrict_access, :only => [:new, :create]  
  
  uses_tiny_mce :only => [:edit, :new, :create], :options => TAZ_TINY_MCE_OPTIONS

   # Use SSL for those actions
   ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :edit_part, :destroy, :destroy_confirmation, :list

   def index   
     index_for_organisation if current_user.is_a?(Organisation)
     index_for_user         if current_user.is_a?(User)
   end
   
   def list
     events = Event.find :all, :conditions => [ "LOWER(title) LIKE ?", 
                                                 '%' + params[:q].to_s.downcase + '%'],
                               :order => "title ASC",
                               :limit => 5
     render :json => events.map{ |event| { :value => event.id, :label => event.title } }
   end
   
   def new
     @event = Event.new
   end

   def create
     @event = Event.new(params[:event])
     @event.originator = current_user
     
     # FIXME Shoud go into model
     # Validate individual
     valid_event = @event.validate_attributes(:only => [:title, :description, :website, :start_date, :start_time, :end_date, :end_time])
     @event.address.errors.clear if @event.address
     valid_address =  @event.location.blank? ? @event.address.validate_attributes(:only => [:city]) : true 
     
     if valid_address and valid_event
       @event.save(false)
       if params[:image]
         @event.image = Image.find(params[:image])
       end       
       redirect_to my_helpedia_event_path(@event)
     else
       if params[:image]
         @event.temp_image = Image.find(params[:image])
       end       
       render :action => "new"
     end
   end   

   def edit
     respond_to do |format|
       format.html { render_partial_for_html("/my_helpedia/events/edit/edit") } 
       format.js { render_partial_for_js("/my_helpedia/events/edit/edit") }       
     end    
   end  

   def show
     redirect_to edit_my_helpedia_event_path(@event)
     #respond_to do |format|
     #  format.html { render_partial_for_html("/my_helpedia/events/show/overview") } 
     #  format.js { render_partial_for_js("/my_helpedia/events/show/overview") }       
     #end    
   end

   def description
     respond_to do |format|
       format.html { render_partial_for_html("/my_helpedia/events/show/description") } 
       format.js { render_partial_for_js("/my_helpedia/events/show/description") }       
     end    
   end
   
   def destroy_confirmation
   end
   
   def destroy
    @event.destroy
    render :update do |page|
      page << "window.location.href='#{my_helpedia_url}'" 
    end
   end

   def update
     # Save the address if delivered
     unless params[:address].blank?
       @event.address.attributes = params[:address] 
       @event.address.save_with_validation(false)
     end    
     
     # Save image if delivered
     unless params[:image].blank?
       @event.image = Image.find(params[:image])
     end     
     
     # Validate the different attributes 
     fields = case params[:part]               
              when "event_data" then [:title, :permalink, :event_category_id, :starts_date, :start_time, :end_date, :end_time]
              when "address" then [:title]                
              when "categories" then [:title]
              when "additional_data" then [:website, :description]                                
              end
     
     @event.attributes = params[:event]
     if @event.validate_attributes(:only => fields)     
       
       # Finally save       
       @event.save_with_validation(false)
       
       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/events/edit/#{params['part']}"
       end    
     else
       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/events/edit/edit_#{params['part']}"
         page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
       end      
     end
   end

   def cancel_edit_part
     render :update do |page|
       page[params['part']].replace_html :partial => "/my_helpedia/events/edit/#{params['part']}"
     end
   end

   def edit_part
     render :update do |page|
       page[params['part']].replace_html :partial => "/my_helpedia/events/edit/edit_#{params['part']}"
       page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
     end
   end 


   private

     ###
     # Rendering for various "index" actions (organiation/organisation)´
     ### 

     def index_for_organisation
       @organisation = current_user
       @events = current_user.committed_events
       build_map(@events,:width => 620, :height => 400) if params[:list_type] == "maps"
       render_index_for("organisations", "Eingetragene Termine")      
     end
     
     def index_for_user
       @user = current_user
       @events = current_user.events
       build_map(@events,:width => 620, :height => 400) if params[:list_type] == "maps"
       render_index_for("users", "Deine eingetragenen Termine")
     end     

     
     def render_index_for(type, list_title = nil)
       respond_to do |format|
          format.html do
            render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                                 :locals => { :content_partial => "/my_helpedia/events/index/show" }
          end    
          format.js do
            render :update do |page|
              page["sub-content-list"].replace_html :partial => "/my_helpedia/events/index/list_#{params[:list_type]}", 
                                               :locals => { :events => @events,
                                                            :list_title => list_title }   
              page.insert_html("after","sub-content",@map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
            end
          end
       end      
     end

     def setup_params
       params[:list_type] = 'cards' if params[:list_type].blank?
     end

     ###
     # "Show" action rendering
     ##

     def render_partial_for_html(partial)
       render :partial => "/my_helpedia/events/show/show", 
                          :layout => true, 
                          :locals => { :content_partial => partial }
     end

     def render_partial_for_js(partial)
       render :update do |page|
         page['sub-content-wrap'].replace_html(render(:partial => partial))
       end    
     end
     
     def find_event
       if current_user.is_a?(Organisation)
         @organisation = current_user
         @event = @organisation.committed_events.find_by_permalink(params[:id])
       else
         @user = current_user         
         @event = @user.events.find_by_permalink(params[:id])
       end
     end 
     
     def restrict_access
       raise Helpedia::ItemNotVisible unless current_user.active?
     end

     def setup
       view_context.main_menu :my_helpedia
     end
  
end
