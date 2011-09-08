class BetaSignupsController < ApplicationController
  
  layout "beta"  
  skip_filter :beta_check
  before_filter :already_beta_user
  
  def index
    @beta_signup = BetaSignup.new
  end
  
  def check_code
    if params[:beta_signup] and params[:beta_signup][:code].downcase == "ich-bin-dabei"
      session[:beta_user] = true
      redirect_to root_path
    else
      @beta_signup = BetaSignup.new(params[:beta_signup])
      flash[:code] = "Das Passwort ist leider nicht korrekt."
      render :action => "index"
      flash.clear
    end
  end
  
  def create
    @beta_signup = BetaSignup.new(params[:beta_signup])
    @beta_signup.ip = request.remote_ip
    if @beta_signup.save
      render :update do |page|
        page["register_form"].replace :partial => "registered"
      end
    else
      render :update do |page|
        page["register_form"].replace :partial => "register_form"
      end
    end
  end
  
  private
  
    def already_beta_user
      redirect_to root_path
      return false
    end
  
end
