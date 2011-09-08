class MyHelpedia::ActivityMembershipsController < ApplicationController

  include ImageHelper
  include GoogleMapsHelper 

  before_filter :setup
  before_filter :find_association
  before_filter :setup_params, :include_gm_header, :only => [:index, :view]
  before_filter :login_required
  
  # Use SSL for those actions
  ssl_required :index, :destroy, :activatem, :view

  def index
    index_for_activity unless params[:activity_id].blank?
    index_for_location unless params[:location_id].blank?
    index_for_organisation unless params[:organisation_id].blank?
    
    index_for_user unless params.has_keys? :activity_id, :location_id, :organisation_id
  end 
  
  def view
    @active = params[:type].to_sym
    @activity_memberships = current_user.send("#{params[:type].to_s.singularize}_activity_memberships")
    build_map(@activity_memberships.map(&:activity), :width => 620, :height => 400) if params[:list_type] == "maps"
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/users/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/activity_memberships/index/users/show" }
      end
      format.js do 
        render :update do |page|
          page["sub-content-list"].replace_html :partial => "/my_helpedia/activity_memberships/index/users/list_#{params[:list_type]}", 
                                                :locals => { :activity_memberships => @activity_memberships }

          page.insert_html("after","sub-content", @map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
        end
      end
    end
  end  
  
  def destroy
    activity_membership = @membershipable.activity_memberships.find(params[:id])
    activity_membership.destroy
    render :update do |page|
      page["div.activity-membership span.tab-icon"].replace_html :text => @membershipable.activity_memberships.count.to_i
      page["li#activity_memberships span.tab-icon"].replace_html :text => @membershipable.activity_memberships.count.to_i
      page["div.activity-membership span.tab-icon"].hide unless @membershipable.activity_memberships.count.to_i > 0
      page["li#activity_memberships span.tab-icon"].hide unless @membershipable.activity_memberships.count.to_i > 0
      page[activity_membership].remove
    end    
  end
  
  def activate
    activity_membership = @activity.activity_memberships.find(params[:id])
    activity_membership.activate!
    
    render :update do |page|
      page["div.activity-membership span.tab-icon"].replace_html :text => @activity.activity_memberships.pending.count.to_i
      page["li#activity_memberships span.tab-icon"].replace_html :text => @activity.activity_memberships.pending. count.to_i
      page["div.activity-membership span.tab-icon"].hide unless @activity.activity_memberships.pending.count.to_i > 0
      page["li#activity_memberships span.tab-icon"].hide unless @activity.activity_memberships.pending.count.to_i > 0
      page["#sub-content-list"].replace_html :text => "Es gibt keine noch nicht freigeschaltene Sympathisanten für diese Aktion." if @activity.activity_memberships.pending.count.to_i < 1
      page[activity_membership].remove
    end
  end 
  
  private
  
    ###
    # Rendering for various "index" actions (organiation/user)
  
    def index_for_activity
      @activity_memberships = @activity.activity_memberships
      render_index_for("activities", "Aktiv beteiligt an der Aktion")
    end
    
    def index_for_location
      @activity_memberships = @location.activity_memberships
      render_index_for("locations", "Aktiv beteiligt an der Aktion")
    end
    
    def index_for_organisation
      @activity_memberships = @organisation.activity_memberships
      render_index_for("organisations", "Aktiv beteiligt an der Aktion")
    end    
    
    def index_for_user
      @active = params[:type].to_sym
      @activity_memberships = current_user.send("#{params[:type].to_s.singularize}_activity_memberships")
      build_map(@activity_memberships, :width => 620, :height => 400) if params[:list_type] == "maps"
      respond_to do |format|
        format.html do 
          render :partial => "/my_helpedia/users/show/show", 
                 :layout => true, :locals => { :content_partial => "/my_helpedia/activity_memberships/index/users/show" }
        end
        format.js do 
          render :update do |page|
            page["sub-content"].replace_html :partial => "/my_helpedia/activity_memberships/index/users/index", 
                                                  :locals => { :activity_memberships => @activity_memberships }

            page.insert_html("after","sub-content", @map.to_html(:no_load => true, :no_script => true)) unless @map.blank?
          end
        end
      end
    end

    def render_index_for(type, title = nil)
      respond_to do |format|
        format.html do
          render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                               :locals => { :content_partial => "/my_helpedia/activity_memberships/index/shared/show" }
        end    
        format.js do
          render :update do |page|             
            page["sub-content-list"].replace_html :partial => "/my_helpedia/activity_memberships/index/shared/list_#{params[:list_type]}", 
                                                  :locals => { :activity_memberships => @activity_memberships, 
                                                  :list_title => title }
          end
        end
      end      
    end 
    
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @membershipable =  $1.classify.constantize.find_by_permalink(value)
          self.instance_variable_set("@#{$1}", @membershipable)
        end
      end
      @user = current_user
    end
   
    def setup_params
      params[:list_type] = 'cards' if params[:list_type].blank?
      params[:type] = :activities if params[:type].blank?
    end    
  
    def setup
      @template.main_menu :my_helpedia
    end
  
  
end
