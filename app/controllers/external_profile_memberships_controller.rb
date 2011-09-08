class ExternalProfileMembershipsController < ApplicationController
  
  def index
     @user = User.find_by_permalink(params[:user_id])
     raise ActiveRecord::RecordNotFound if @user.blank?
     raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)     
     render :partial => "/users/show/show", :layout => true, :locals => {:content_partial => "/external_profile_memberships/index"}
  end

end
