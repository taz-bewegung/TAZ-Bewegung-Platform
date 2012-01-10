class MyHelpedia::JobsController < ApplicationController

  include ImageHelper 

  before_filter :find_job, :only => [:show, :update, :edit, :update, :description, :edit_part, :cancel_edit_part]  
  before_filter :setup
  before_filter :setup_params, :include_gm_header, :only => [:index]  
  before_filter :login_required
  before_filter :organisation_login_required, :only => [:new, :create, :edit, :update]   
  
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :destroy, :edit_part   
  
  def index   
    index_for_organisation unless params[:organisation_id].blank?    
  end
  
  def edit
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/jobs/edit/edit") } 
      format.js { render_partial_for_js("/my_helpedia/jobs/edit/edit") }       
    end    
  end  
  
  def show
    redirect_to edit_my_helpedia_organisation_job_path(@organisation, @job)
    #respond_to do |format|
    #  format.html { render_partial_for_html("/my_helpedia/jobs/show/overview") } 
    #  format.js { render_partial_for_js("/my_helpedia/jobs/show/overview") }       
    #end    
  end
  
  def description
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/jobs/show/description") } 
      format.js { render_partial_for_js("/my_helpedia/jobs/show/description") }       
    end    
  end
  
  def new
   @job = Job.new
  end


  def create
    @job = Job.new(params[:job])
    @job.organisation = current_user 

    if @job.save
      flash[:notice] = 'Job was successfully created.'
      redirect_to(@job)
    else
      render :action => "new"
    end         
  end

   def update
     # Save the address if delivered
     unless params[:address].blank?
       @job.address.attributes = params[:address] 
       @job.address.save_with_validation(false)
     end 
    
     # Save image if delivered
     unless params[:document].blank?
       @job.document = Document.find(params[:document])
     end     
     
     # Validate the different attributes 
     fields = case params[:part]
              when "about" then [:requirements, :duties, :offer, :remark]
              when "address" then [:title]
              when "documents" then [:title]                
              when "job_data" then [:title, :permalink, :duration, :salary, :occupation_type_id, :starts_on, :expires_on]
              when "job_contact" then [:contact_name, :contact_phone, :contact_email, :contact_name]
              end
     
     @job.attributes = params[:job]
     if @job.validate_attributes(:only => fields)
       
       # Finally save
       @job.save_with_validation(false)     

       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/jobs/edit/#{params['part']}"
       end    
     else
       render :update do |page|
         page[params['part']].replace_html :partial => "/my_helpedia/jobs/edit/edit_#{params['part']}"
       end      
     end
   end

   def cancel_edit_part
     render :update do |page|
       page[params['part']].replace_html :partial => "/my_helpedia/jobs/edit/#{params['part']}"
     end
   end

   def edit_part
     render :update do |page|
       page[params['part']].replace_html :partial => "/my_helpedia/jobs/edit/edit_#{params['part']}"
     end    
   end 


   private

     ###
     # Rendering for various "index" actions (organiation/organisation)´
     ### 

     def index_for_organisation
       @organisation = Organisation.find_by_permalink(params[:organisation_id])
       @jobs = @organisation.jobs
       build_map(:width => 665, :height => 400) if params[:list_type] == "maps"            
       render_index_for("organisations", "Aktionen für unsere Organisation")      
     end

     
     def render_index_for(type, list_title = nil)
       respond_to do |format|
          format.html do
            render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                                 :locals => { :content_partial => "/my_helpedia/jobs/index/#{type}/show" }
          end    
          format.js do
            render :update do |page|
              page["sub-content-list"].replace_html :partial => "/my_helpedia/jobs/index/#{type}/list_#{params[:list_type]}", 
                                               :locals => { :jobs => @jobs,
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
       render :partial => "/my_helpedia/jobs/show/show", 
                          :layout => true, 
                          :locals => { :content_partial => partial }
     end

     def render_partial_for_js(partial)
       render :update do |page|
         page['sub-content-wrap'].replace_html :partial => partial
       end    
     end
     
     # Google maps
     def build_map(options = {})
       @map = GMap.new("map_div")
       @map.control_init(:large_map => true, :hierarchical_map_type => true)
       @map.center_zoom_init([GEOCODE_DEFAULT_LOCATION["lat"], GEOCODE_DEFAULT_LOCATION["lng"]],5)
       @map.add_map_type_init(GMapType::G_PHYSICAL_MAP)      
       @map.set_map_type_init(GMapType::G_PHYSICAL_MAP)
       @map.clear_overlays 
       @map.width = options[:width]
       @map.height = options[:height]      

       # create markers for map
       icon = GIcon.new(:shadow => "/images/markers/helpedia_marker_shadow.png",
         :image => '/images/markers/helpedia_marker.png',
         :iconSize => GSize.new(21, 29),
         :shadowSize => GSize.new(37, 29),
         :iconAnchor => GPoint.new(9, 29),
         :infoWindowAnchor => GPoint.new(9, 2),
         :infoShadowAnchor => GPoint.new(18, 25)
       ) 

       markers = []
       for job in @jobs
         tooltip = view_context.content_tag :div, view_context.link_to(job.title, my_helpedia_job_path(job)), :class => "title" 
         tooltip << view_context.content_tag(:div, view_context.link_to(image_for(job.organisation, :mini), my_helpedia_job_path(job)), :class => "image")        

         content = "<dl><dt>Angebot von:</dt><dd>#{view_context.link_to(job.organisation.name, organisation_path(job.organisation))}</dd>"
         content << "<dt>Art des Jobs:</dt><dd>#{job.occupation_type.name}</dd>"
         content << "<dt>Adresse:</dt><dd>#{job.address.to_html_long}</dd></dl>"

         tooltip << view_context.content_tag(:div, content, :class => "address")
         tooltip = view_context.content_tag(:div, tooltip, :class => "info-window")
         marker = GMarker.new([job.address.lat, job.address.lng], :title => job.title, :info_window => tooltip, :icon => icon)
         markers << marker
       end      
       clusterer = Clusterer.new(markers, :icon => icon, :max_visible_markers => 100)           
       @map.overlay_init clusterer
     end        


     def find_job
       @organisation = current_user
       @job = @organisation.jobs.find_by_permalink(params[:id])      
     end

     def setup
       view_context.main_menu :my_helpedia
       view_context.search_default :activities         
     end
  
end
