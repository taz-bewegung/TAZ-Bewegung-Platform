class MyHelpedia::FeedEventsController < ApplicationController
  
  before_filter :login_required
  before_filter :setup
  
  def index
    @user, @organisation = current_user, current_user
    @feed_events = current_user.aggregated_feed_events.public_visible.latest.paginate(:page => params[:page], :per_page => 20)
    @grouped_events = @feed_events.group_by { |e| I18n.l(e.created_at.to_date, :format => "%d. %B %Y") }    
    respond_to do |format|
       format.html do
         render :partial => "/my_helpedia/#{current_user.class.to_s.downcase.pluralize}/show/show", 
                :layout => true,
                :locals => { :content_partial => "/my_helpedia/feed_events/index" }                
       end    
       format.js do
         if params[:without_layout]
           @continuend = current_user.aggregated_feed_events.public_visible.latest.find(:first, 
                                                                                           :conditions => ["feed_events.created_at BETWEEN ? AND ? AND feed_events.uuid != ?", 
                                                                                               events.first.created_at.beginning_of_day, 
                                                                                               events.first.created_at,
                                                                                               events.first.uuid]).present?           
           render :partial => "/feed_events/list"
         else
           render :update do |page|
             page["sub-content"].replace_html :partial => "index_list"
           end
         end
       end
    end
  end


  def around
    @user, @organisation = current_user, current_user    
    @feed_events = FeedEvent.around(current_user.address).public_visible.latest.paginate(:page => params[:page], :per_page => 20)
    @grouped_events = @feed_events.group_by { |e| I18n.l(e.created_at.to_date, :format => "%d. %B %Y") }    
    respond_to do |format|
       format.html do
         render :partial => "/my_helpedia/#{current_user.class.to_s.downcase.pluralize}/show/show", 
                :layout => true,
                :locals => { :content_partial => "/my_helpedia/feed_events/around" }                
       end    
       format.js do
         if params[:without_layout]
           @continuend = FeedEvent.around(current_user.address).public_visible.latest.find(:first, 
                                                                                           :conditions => ["feed_events.created_at BETWEEN ? AND ? AND feed_events.uuid != ?", 
                                                                                               events.first.created_at.beginning_of_day, 
                                                                                               events.first.created_at,
                                                                                               events.first.uuid]).present?           
           render :partial => "/feed_events/list"
         else
           render :update do |page|
             page["sub-content"].replace_html :partial => "around"
           end
         end
       end
    end
  end  

  
  private
  
    def setup
      view_context.main_menu :my_helpedia  
    end      
  
end
