# encoding: UTF-8
class ActivityMembershipsController < ApplicationController

  include ImageHelper 
  include GoogleMapsHelper   

  before_filter :login_required, :except => [:index]
  before_filter :user_login_required, :only => [:new, :create]
  before_filter :find_association
  before_filter :setup
  before_filter :setup_params, :only => [:index]

  def index
    
    unless params.has_keys? :activity_id, :location_id, :organisation_id
      index_for_member
    else
      index_for_memberable
    end
  end 
  
  def index_for_member
    @active = params[:type].to_sym
    @user = User.find_by_permalink params[:user_id]
    @activity_memberships = @user.send("#{params[:type].to_s.singularize}_activity_memberships")
    build_map(@activity_memberships, :width => 620, :height => 400) if params[:list_type] == "maps"
    respond_to do |format|
      format.html do 
        render :partial => "/users/show/show", 
               :layout => true, :locals => { :content_partial => "/activity_memberships/index/users/show" }
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => "/activity_memberships/index/users/index", 
                                                :locals => { :activity_memberships => @activity_memberships }
    
          page.insert_html("after","sub-content", @map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
        end
      end
    end
  end
  
  def view
    @active = params[:type].to_sym
    @user = User.find_by_permalink params[:user_id]    
    @activity_memberships = @user.send("#{params[:type].to_s.singularize}_activity_memberships")
    build_map(@activity_memberships.map(&:activity), :width => 620, :height => 400) if params[:list_type] == "maps"
    respond_to do |format|
      format.html do 
        render :partial => "/users/show/show", 
               :layout => true, :locals => { :content_partial => "/activity_memberships/index/users/show" }
      end
      format.js do 
        render :update do |page|
          page["sub-content-list"].replace_html :partial => "/activity_memberships/index/users/list_#{params[:list_type]}", 
                                                :locals => { :activity_memberships => @activity_memberships }

          page.insert_html("after","sub-content", @map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
        end
      end
    end
  end
  
  def index_for_memberable
    @activity_memberships = @membershipable.activity_memberships.active_with_user
    respond_to do |format|
       format.html do
         render :partial => "/#{@membershipable.class.to_s.downcase.pluralize}/show/show", :layout => true, 
                            :locals => { :content_partial => "/activity_memberships/index/shared/show", :sub_menu_active => :activity_memberships }
       end    
       format.js do
         render :update do |page|
           
           page["sub-content-list"].replace_html :partial => "/activity_memberships/index/shared/list_#{params[:list_type]}", 
                                                 :locals => { :activity_memberships => @activity_memberships, :sub_menu_active => :activity_memberships }
 
         end
       end
    end    
  end
  
  def new
    @activity_membership = @membershipable.activity_memberships.new
    render :partial => "new"
  end
  
  def create
    @activity_membership = ActivityMembership.new(params[:activity_membership])
    @activity_membership.user = current_user
    @activity_membership.activity = @membershipable
    if @activity_membership.save
      @activity_membership.activate!
      render :update do |page|
        page << "window.location.href = '#{polymorphic_url([@membershipable, :activity_memberships])}';"
      end
    else
      render :update do |page|
        page['#nyroModalContent'].replace_html :partial => "new"
      end
    end
  end  
  
  private
  
    ###
    # Rendering for various "index" actions (organiation/user)´
    ### 
  
    def index_for_activity
      @activity = Activity.find_by_permalink(params[:activity_id], :include => :activity_memberships)
      @activity_memberships = @activity.activity_memberships.active_with_user
      render_index_for("activity")
    end 
    
    def render_index_for(type)
      respond_to do |format|
         format.html do
           render :partial => "/activities/show/show", :layout => true, 
                                                       :locals => { :content_partial => "/activity_memberships/index/#{type}/show", :sub_menu_active => :activity_memberships }
         end    
         format.js do
           render :update do |page|
             
             page["sub-content-list"].replace_html :partial => "/activity_memberships/index/shared/list_#{params[:list_type]}", 
                                                   :locals => { :activity_memberships => @activity_memberships, :sub_menu_active => :activity_memberships }
   
           end
         end
      end      
    end 
    
    # Finds the associations
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @membershipable =  $1.classify.constantize.find_by_permalink(value)
          self.instance_variable_set("@#{$1}", @membershipable)
        end
      end
      raise Helpedia::ItemNotVisible unless @membershipable.visible_for?(current_user)
    end
    
    
    def setup_params
      params[:list_type] = 'cards' if params[:list_type].blank?
      params[:type] = :activities if params[:type].blank?
    end    
 
  
    def setup
      view_context.main_menu @membershipable.class.to_s.pluralize.downcase.to_sym
    end
  
end
