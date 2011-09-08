class AdminController < ApplicationController
  
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'
  
  ssl_required :index  
  
  def index
  end
    
end
