# encoding: UTF-8
class Admin::LocationsController < ApplicationController
  
  layout "admin"
  
  before_filter :login_required, :setup
  before_filter :find_location, :only => [:edit, :update, :update_comment, 
                                          :destroy_confirmation, :destroy, :suspend_confirmation, :suspend, :activate_confirmation, :activate]
  
  ssl_required :index, :suspended, :activate, :reactivate, :suspend, :update, :edit,
               :update_comment, :suspend_confirmation, :destroy, :destroy_confirmation, :activate_confirmation, :activate
  access_control :DEFAULT => '(admin | news)'
  uses_tiny_mce :only => [:edit, :update], :options => TAZ_TINY_MCE_OPTIONS  
  
  def index
    @search = Search::Admin::Location.new(params[:search_admin_location])
    @search.add_condition(["locations.state = 'active'"])    
    @locations = @search.search(params[:page])
    @path = admin_locations_path     
  end
  
  def suspended
    @search = Search::Admin::Location.new(params[:search_admin_location])
    @search.add_condition(["locations.state = 'suspended'"])
    @locations = @search.search(params[:page])
    @path = suspended_admin_locations_path     
  end
     
  ##
  # Single location actions 
  
  def edit
    params[:location] = {}
  end
  
  def update 
    @location.attributes = params[:location]
    if @location.save
      redirect_to admin_locations_path
    else
      render :action => :edit
    end    
  end
  
  def update_comment
    @location.update_attribute(:admin_comment, params[:value])
    render :text => @location.admin_comment
  end
  
  def activate_confirmation
    @message = Message.new :subject => t(:"system_message.location.activate.subject", :title => h(@location.title)),
                            :body => t(:"system_message.location.activate.message")
   render :partial => "confirmation", :locals => { :partial => "activate_confirmation.html.erb"}                             
  end
  
  def activate
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @location.owner,
                           :system_message => true }
    message.deliver
    @location.activate!
    render :update do |page|
      page << "$.nyroModalRemove();" 
      page[@location].remove
    end
  end   
  
  
  def suspend_confirmation
    @message = Message.new :subject => t(:"system_message.location.suspend.subject", :title => h(@location.title)),
                           :body => t(:"system_message.location.suspend.message")
    render :partial => "confirmation", :locals => { :partial => "suspend_confirmation.html.erb"}
  end
  
  def suspend
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @location.owner,
                           :system_message => true }
    message.deliver
    @location.suspend!
    render :update do |page|
      page << "$.nyroModalRemove();"
      page[@location].remove
    end
  end  
  
  def destroy_confirmation
    @message = Message.new :subject => t(:"system_message.location.destroy.subject", :title => h(@location.title)),
                           :body => t(:"system_message.location.destroy.message")
    render :partial => "confirmation", :locals => { :partial => "destroy_confirmation.html.erb"}                                                        
  end
  
  def destroy
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @location.owner,
                           :system_message => true }
    message.deliver
    @location.destroy
    render :update do |page|
      page << "$.nyroModalRemove();" 
      page[@location].remove
    end    
  end
  
  private
  
    def find_location
      @location = Location.find_by_permalink(params[:id])
    end

    def setup
      params[:search_admin_location] = {} if params[:search_admin_location].blank?
    end
  
  
  
  
end
