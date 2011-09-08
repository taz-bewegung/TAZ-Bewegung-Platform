class MyHelpedia::ExternalProfileMembershipsController < ApplicationController
  
  before_filter :find_user
  before_filter :login_required
  before_filter :user_login_required
  
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :destroy
  
  def new   
    @external_profile_membership = @user.external_profile_memberships.new    
    @form_url = my_helpedia_user_external_profile_memberships_path(@user, :part => @external_profile_membership.object_id)
    render :update do |page|
      page.insert_html :after, 'create_membership', :partial => "form"
      page << "$('##{params[:spinner]}').toggle();"
    end
  end
  
  def create
    @external_profile_membership = ExternalProfileMembership.new(params[:external_profile_membership])
    @form_url = my_helpedia_user_external_profile_memberships_path(@user, :part => @external_profile_membership.object_id)
    @external_profile_membership.user = current_user
    @external_profile_membership.external_profile = ExternalProfile.find_by_title "Homepage"
    if @external_profile_membership.save    
      render :update do |page|
        page[params[:part]].replace_html :partial => "item", :locals => { :external_profile_membership => @external_profile_membership }
      end
    else
      render :update do |page|
        page[params[:part]].replace_html :partial => "form"
      end      
    end
  end
  
  def edit
    @external_profile_membership = @user.external_profile_memberships.find(params[:id])    
    @form_url = my_helpedia_user_external_profile_membership_path(@user, @external_profile_membership, :part => @external_profile_membership.object_id)        
    render :update do |page|
      page[params[:part]].replace_html :partial => "form"
      page << "$('##{params[:spinner]}').toggle();"      
    end    
  end
  
  def update
    @external_profile_membership = @user.external_profile_memberships.find(params[:id]) 
    @form_url = my_helpedia_user_external_profile_membership_path(@user, @external_profile_membership, :part => @external_profile_membership.object_id)            
    if @external_profile_membership.update_attributes(params[:external_profile_membership])    
      render :update do |page|
        page[params[:part]].replace_html :partial => "item", :locals => { :external_profile_membership => @external_profile_membership }
      end
    else
      render :update do |page|
        page[params[:part]].replace_html :partial => "form"
      end      
    end    
  end
  
  def cancel_edit_part
    if params[:id] != "0"
      @external_profile_membership = @user.external_profile_memberships.find(params[:id]) 
      render :update do |page|
        page[params[:part]].replace :partial => "item", :locals => { :external_profile_membership => @external_profile_membership }
      end    
    else
      render :update do |page|
        page[params[:part]].remove
      end      
    end
  end
  
  def destroy
    external_profile_membership = @user.external_profile_memberships.find(params[:id])     
    external_profile_membership.destroy
    render :update do |page|
      page[params[:part]].remove
    end    
  end
  
  private
  
    def find_user
      @user = current_user
    end
end
