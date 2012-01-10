class MyHelpedia::EngagementsController < ApplicationController

  before_filter :setup
  before_filter :setup_params, :find_engagements, :only => [:index]
  before_filter :login_required
  
  def index
    respond_to do |format|
       format.html do
         render :partial => "/my_helpedia/user_index", :layout => true, 
                                                       :locals => { :content_partial => 'user_index' }
       end
       
       format.js do
         render :update do |page|
           page["sub-content"].replace_html :partial => "list_#{params[:list_type]}", :locals => { :engagements => @engagements }             
         end
       end
    end
      
  end
  
  def show
    @engagement = Engagement.find_by_permalink(params[:id], :include => [:user, :organisation])     
  end
  
  def statistics
    @engagement = Engagement.find_by_permalink(params[:id])         
  end
  
  private
    
    def find_engagements
      @user = current_user
      @engagements = @user.engagements.by_filter(params[:filter])      
    end
  
    def setup_params
      params[:filter] = { :running => "1", :waiting => "1", :finished => "1" } if params[:filter].blank?    
      params[:list_type] = 'card' if params[:list_type].blank?
    end
    
    def setup
      view_context.main_menu :my_helpedia
    end
    
end
