# encoding: UTF-8
class Admin::BetaUsersController < ApplicationController

  layout 'admin'
  ssl_required  :index
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'

  def index
    @users = BetaSignup.paginate(:page => params[:page], :per_page => 60, :order => "created_at DESC")
  end


end