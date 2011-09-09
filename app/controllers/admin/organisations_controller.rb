# encoding: UTF-8
class Admin::OrganisationsController < ApplicationController
  
  layout 'admin'
  before_filter :setup  
  before_filter :user_login_required
  before_filter :find_organisation, :only => [:update, :show, :edit, :simulate, :suspend, :activate, :reactivate, :update_comment]
  access_control :DEFAULT => '(admin | news)'  
  ssl_required :index, :not_activated, :suspended, :simulate, :reactivate, :suspend, :update, :edit, :update_comment, :activate
 
  

  # Collection methods
  
  def index
    @search = Search::Admin::Organisation.new(params[:search_admin_organisation])
    @search.add_condition(["organisations.state = 'active'"])    
    @organisations = @search.search(params[:page])
    @path = admin_organisations_path
    
    respond_to do |format|
      format.html do
        render  'admin/organisations/index', :layout => true
      end
      format.js do
        render :update do |page|
          page["sub-content-list"].replace_html :partial => 'table', :collection => @organisations
        end
      end
    end
    
  end
  
  def not_activated 
    @search = Search::Admin::Organisation.new(params[:search_admin_organisation])
    @search.add_condition(["organisations.state = 'pending'"])
    @organisations = @search.search(params[:page])
    @path = not_activated_admin_organisations_path
  end
  
  def suspended
    @search = Search::Admin::Organisation.new(params[:search_admin_organisation])
    @search.add_condition(["organisations.state = 'suspended'"])
    @organisations = @search.search(params[:page])
    @path = suspended_admin_organisations_path
  end

  
  # Single organisation methods
  
  def update
    @organisation.update_attributes(params[:organisation])
    render :update do |page|
      page["orga-#{@organisation.id}"].highlight
    end
  end 
  
  def suspend
    @organisation.suspend!
    redirect_to :back    
  end
  
  def reactivate
    @organisation.update_attribute :state, 'active'
    redirect_to :back    
  end
  
  def simulate
    simulate_user(@organisation)
    redirect_to my_helpedia_path
  end
  
  # Activates an organisation
  def activate
    #@organisation.activated_by = current_user.id
    @organisation.activate!
    redirect_to :back
  end    
  
  def edit
    render :update do |page|
      page["notice_#{@organisation.id}"].replace_html :partial => "notice"
    end    
  end
  
  def update
    @organisation.attributes = params[:organisation]
    @organisation.save_with_validation(false)
    render :update do |page|
      page["notice_#{@organisation.id}"].replace_html notice_of_excemption_status_for(@organisation)
    end    
  end

  def update_comment
    @organisation.update_attribute(:admin_comment, params[:value])
    render :text => @organisation.admin_comment
  end
 
 
 private 
 
   def find_organisation
     @organisation = Organisation.find_by_permalink(params[:id])
   end
 
   def setup
     params[:search_admin_organisation] = {} if params[:search_admin_organisation].blank?
   end      
  
end
