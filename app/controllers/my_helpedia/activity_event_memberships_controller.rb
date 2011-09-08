class MyHelpedia::ActivityEventMembershipsController < ApplicationController

  before_filter :find_activity
  before_filter :login_required

  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :update, :cancel_edit_part, :destroy, :event_list, :activity_list
  
  def event_list
#    events = Event.find :all, :conditions => [ "LOWER(title) LIKE ? AND uuid NOT IN (?)", 
#                                                '%' + params[:q].to_s.downcase + '%', @activity.events.map(&:id)],
#                              :order => "title ASC",
#                              :limit => 5
    events = Event.find :all, :conditions => [ "LOWER(title) LIKE ?", 
                                                '%' + params[:q].to_s.downcase + '%'],
                              :order => "title ASC",
                              :limit => 5                              
    render :json => events.map{ |event| { :value => event.id, :label => event.title } }
  end
  
  def activity_list
    @event = Event.find_by_permalink(params[:id])
    activities = Activity.find :all, :conditions => [ "LOWER(title) LIKE ?", 
                                                      '%' + params[:q].to_s.downcase + '%'],
                              :order => "title ASC",
                              :limit => 5
    render :json => activities.map{ |activity| { :value => activity.id, :label => activity.title } }
  end  

  def new   
    @activity_event_membership = @activity.activity_event_memberships.build
    @form_url = my_helpedia_activity_activity_event_memberships_path(@activity, :part => @activity_event_membership.object_id)
    render :update do |page|
      page.insert_html :after, 'create_membership', :partial => "form"
      page << "$('##{params[:spinner]}').toggle();"
    end
  end

  def create
    @activity_event_membership = ActivityEventMembership.new(params[:activity_event_membership])
    @form_url = my_helpedia_activity_activity_event_memberships_path(@activity, :part => @activity_event_membership.object_id)
    @activity_event_membership.activity = @activity
    if @activity_event_membership.save
      render :update do |page|
        page[params[:part]].replace_html :partial => "item", :locals => { :activity_event_membership => @activity_event_membership }
      end
    else
      render :update do |page|
        page[params[:part]].replace_html :partial => "form"
      end      
    end
  end

  def edit
    @activity_event_membership = @activity.activity_event_memberships.find(params[:id])    
    @form_url = my_helpedia_activity_activity_event_membership_path(@activity, @activity_event_membership, :part => @activity_event_membership.object_id)        
    render :update do |page|
      page[params[:part]].replace_html :partial => "form"
      page << "$('##{params[:spinner]}').toggle();"      
    end    
  end

  def update
    @activity_event_membership = @activity.activity_event_memberships.find(params[:id]) 
    @form_url = my_helpedia_activity_activity_event_membership_path(@activity, @activity_event_membership, :part => @activity_event_membership.object_id)            
    if @activity_event_membership.update_attributes(params[:activity_event_membership])    
      render :update do |page|
        page[params[:part]].replace_html :partial => "item", :locals => { :activity_event_membership => @activity_event_membership }
      end
    else
      render :update do |page|
        page[params[:part]].replace_html :partial => "form"
      end      
    end    
  end

  def cancel_edit_part
    if params[:id] != "0"
      @activity_event_membership = @activity.activity_event_memberships.find(params[:id]) 
      render :update do |page|
        page[params[:part]].replace :partial => "item", :locals => { :activity_event_membership => @activity_event_membership }
      end    
    else
      render :update do |page|
        page[params[:part]].remove
      end      
    end
  end

  def destroy
    activity_event_membership = @activity.activity_event_memberships.find(params[:id])
    activity_event_membership.destroy
    render :update do |page|
      page[params[:part]].remove
      page[params[:spinner]].hide
    end    
  end

  private

    def find_activity
      @activity = Activity.find_by_permalink(params[:activity_id])
    end
  
  
end
