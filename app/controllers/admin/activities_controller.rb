class Admin::ActivitiesController < ApplicationController
  
  layout "admin"
  
  before_filter :login_required, :setup
  before_filter :find_activity, :only => [:edit, :update, :update_comment, 
                                          :destroy_confirmation, :destroy, :suspend_confirmation, :suspend, :activate_confirmation, :activate]
  
  ssl_required :index, :suspended, :activate, :reactivate, :suspend, :update, :edit,
               :update_comment, :suspend_confirmation, :destroy, :destroy_confirmation, :activate_confirmation, :activate
  access_control :DEFAULT => '(admin | news)'
  uses_tiny_mce :only => [:edit, :update], :options => TAZ_TINY_MCE_OPTIONS  
  
  def index
    @search = Search::Admin::Activity.new(params[:search_admin_activity])
    @search.add_condition(["activities.state = 'active'"])    
    @activities = @search.search(params[:page])
    @path = admin_activities_path
  end
  
  def suspended
    @search = Search::Admin::Activity.new(params[:search_admin_activity])
    @search.add_condition(["activities.state = 'suspended'"])
    @activities = @search.search(params[:page])
    @path = suspended_admin_activities_path     
  end

  ##
  # Single activity actions 
  
  def edit
    params[:activity] = {}
  end
  
  def update 
    @activity.attributes = params[:activity]
    if @activity.save
      redirect_to admin_activities_path
    else
      render :action => :edit
    end    
  end
  
  def update_comment
    @activity.update_attribute(:admin_comment, params[:value])
    render :text => @activity.admin_comment
  end
  
  def activate_confirmation
    @message = Message.new :subject => t(:"system_message.activity.activate.subject", :title => h(@activity.title)),
                            :body => t(:"system_message.activity.activate.message")
   render :partial => "confirmation", :locals => { :partial => "activate_confirmation.html.erb"}                             
  end
  
  def activate
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @activity.owner,
                           :system_message => true }
    message.deliver
    @activity.activate!
    render :update do |page|
      page << "$.nyroModalRemove();" 
      page[@activity].remove
    end
  end   
  
  
  def suspend_confirmation
    @message = Message.new :subject => t(:"system_message.activity.suspend.subject", :title => h(@activity.title)),
                           :body => t(:"system_message.activity.suspend.message")
    render :partial => "confirmation", :locals => { :partial => "suspend_confirmation.html.erb"}
  end
  
  def suspend
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @activity.owner,
                           :system_message => true }
    message.deliver
    @activity.suspend!
    render :update do |page|
      page << "$.nyroModalRemove();"
      page[@activity].remove
    end
  end  
  
  def destroy_confirmation
    @message = Message.new :subject => t(:"system_message.activity.destroy.subject", :title => h(@activity.title)),
                           :body => t(:"system_message.activity.destroy.message")
    render :partial => "confirmation", :locals => { :partial => "destroy_confirmation.html.erb"}                                                        
  end
  
  def destroy
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @activity.owner,
                           :system_message => true }
    message.deliver
    @activity.destroy
    render :update do |page|
      page << "$.nyroModalRemove();" 
      page[@activity].remove
    end    
  end
  
  private
  
    def find_activity
      @activity = Activity.find_by_permalink(params[:id])
    end

    def setup
      params[:search_admin_activity] = {} if params[:search_admin_activity].blank?
    end
  
  
  
  
end
