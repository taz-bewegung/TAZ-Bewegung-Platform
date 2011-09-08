class Admin::RolesController < ApplicationController
  
  layout 'admin'
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'  
  
  def index
    @roles = Role.find(:all, :include => [:users])
  end
  
end
