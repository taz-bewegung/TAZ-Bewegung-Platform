class Admin::JobsController < ApplicationController
  
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'
  
end
