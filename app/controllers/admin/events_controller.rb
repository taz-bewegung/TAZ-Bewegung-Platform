class Admin::EventsController < ApplicationController
  
  layout "admin"
  
  before_filter :login_required, :setup
  before_filter :find_event, :only => [:edit, :update, :update_comment, 
                                       :destroy_confirmation, :destroy, :suspend_confirmation, :suspend, :activate_confirmation, :activate]
  
  ssl_required :index, :suspended, :activate, :reactivate, :suspend, :update, :edit,
               :update_comment, :suspend_confirmation, :destroy, :destroy_confirmation, :activate_confirmation, :activate
  access_control :DEFAULT => '(admin | news)'
  uses_tiny_mce :only => [:edit, :update], :options => TAZ_TINY_MCE_OPTIONS
  
  def index
    @search = Search::Admin::Event.new(params[:search_admin_event])
    @search.add_condition(["events.state = 'active'"])
    @events = @search.search(params[:page])
    @path = admin_events_path
  end
  
  def suspended
    @search = Search::Admin::Event.new(params[:search_admin_event])
    @search.add_condition(["events.state = 'suspended'"])
    @events = @search.search(params[:page])
    @path = suspended_admin_events_path
  end
  
  ##
   # Single event actions 

   def edit
     params[:event] = {}
   end

   def update 
     @event.attributes = params[:event]
     if @event.save
       redirect_to admin_events_path
     else
       render :action => :edit
     end    
   end

   def update_comment
     @event.update_attribute(:admin_comment, params[:value])
     render :text => @event.admin_comment
   end      
   
   def activate_confirmation
     @message = Message.new :subject => t(:"system_message.event.activate.subject", :title => h(@event.title)),
                             :body => t(:"system_message.event.activate.message")
    render :partial => "confirmation", :locals => { :partial => "activate_confirmation.html.erb"}                             
   end
   
   def activate
     message = Message.new(params[:message])
     message.attributes = { :sender => current_user,
                            :recipient => @event.owner,
                            :system_message => true }
     message.deliver
     @event.activate!
     render :update do |page|
       page << "$.nyroModalRemove();" 
       page[@event].remove
     end
   end   

   def suspend_confirmation
     @message = Message.new :subject => t(:"system_message.event.suspend.subject", :title => h(@event.title)),
                            :body => t(:"system_message.event.suspend.message")    
    render :partial => "confirmation", :locals => { :partial => "suspend_confirmation.html.erb"}
   end

   def suspend
     message = Message.new(params[:message])
     message.attributes = { :sender => current_user,
                            :recipient => @event.owner,
                            :system_message => true }
     message.deliver
     @event.suspend!
     render :update do |page|
       page << "$.nyroModalRemove();" 
       page[@event].remove       
     end
   end  

   def destroy_confirmation
     @message = Message.new :subject => t(:"system_message.event.destroy.subject", :title => h(@event.title)),
                            :body => t(:"system_message.event.destroy.message")
    render :partial => "confirmation", :locals => { :partial => "destroy_confirmation.html.erb"}
   end

   def destroy
     message = Message.new(params[:message])
     message.attributes = { :sender => current_user,
                            :recipient => @event.owner,
                            :system_message => true }
     message.deliver
     @event.destroy
     render :update do |page|
       page << "$.nyroModalRemove();" 
       page[@event].remove
     end    
   end  
    
  private
  
    def find_event
      @event = Event.find_by_permalink(params[:id])
    end

    def setup
      params[:search_admin_event] = {} if params[:search_admin_event].blank?
    end
  
end
