class MyHelpedia::WidgetsController < ApplicationController
  
  before_filter :setup
  
  # Use SSL for those actions
  ssl_required :index  
  
  def index

    index_for_activity unless params[:activity_id].blank?

    # Genrell organisation widget
    index_for_organisation unless params[:organisation_id].blank?
  end  
    
  private
  
    # Shows the widget latest widgets for organisations
    def index_for_organisation
      @organisation = current_user    
      @latest_activity = Activity.latest.running.find_by_organisation_id(@organisation)    
      @latest_condolence_activity = Activity.latest.condolence.running.find_by_organisation_id(@organisation)    
      @latest_social = Activity.latest.social.running.find_by_organisation_id_and_honory_office(@organisation, true)

      render_index_for("organisations")
    end

    def index_for_activity
      @activity = Activity.find_by_permalink(params[:activity_id])
      render_index_for("activities")                                
    end
  
    def render_index_for(type, list_title = nil)
      respond_to do |format|
         format.html do
           render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                                :locals => { :content_partial => "/my_helpedia/widgets/index/#{type}" }
         end    
         format.js do
           render :update do |page|
             page["sub-content-list"].replace_html :partial => "/my_helpedia/activities/index/#{type}/list_#{params[:list_type]}", 
                                                   :locals => { :activities => @activities,
                                                                :list_title => list_title }   
           end
         end
      end      
    end  

    def setup
      view_context.main_menu :my_helpedia
    end
    
end
