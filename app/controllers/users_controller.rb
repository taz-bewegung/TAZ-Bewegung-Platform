# encoding: UTF-8
class UsersController < ApplicationController
    
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :show]
  before_filter :check_visibility, :only => [:show]  
  before_filter :check_for_user, :only => [:new, :create]

  ssl_required :new, :create
  
  def index
  end
  
  def show
    respond_to do |format|
      format.html { render_partial_for_html("/users/show/overview") }
      format.js { render_partial_for_js("/users/show/overview") }
    end    
  end
    
  # render new.rhtml
  def new
    @user = User.new
    render :layout => "application"
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    if @user.validate_attributes(:only => [:first_name, :last_name, :email, :password, :password_confirmation, :permalink])
      @user.register!
      redirect_to registered_users_path
    else
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    user = Organisation.find_by_activation_code(params[:activation_code]) if not params[:activation_code].blank? and user.blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = I18n.t(:"user.activated.message")
      session[:beta_user] = true      
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = I18n.t(:"user.activated.error")
      redirect_to login_path
    else 
      flash[:error]  = I18n.t(:"user.activated.error")
      session[:beta_user] = true
      redirect_to login_path
    end
  end
  
  
  #for Fairdo Migration
  
  def get_password
    logout_keeping_session!
    @user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    raise ActiveRecord::RecordNotFound if @user.blank?
    
    render "set_password"
  end
  
  def set_password
    #debugger
    @user = User.find(params[:user][:uuid])
    raise ActiveRecord::RecordNotFound if @user.blank?
    @user.attributes = params[:user]
  
    if @user.valid? && @user.accept_taz_agb
      @user.save
      @user.activate!
      UserMailer.deliver_fairdo_activation(@user)
      #flash[:notice] = I18n.t(:"user.activated.message")
      self.current_user = @user
      redirect_to root_path
    else
      unless @user.accept_taz_agb
        flash[:error] = "Bitte die AGBs akzeptieren"
      end
    end    
  end
  
  def delete_fairdouser
    user = User.find(params[:id])
    user.destroy
    redirect_to :root
  end

protected 

  def check_for_user
    redirect_back_or_default("/") if current_user
  end

  def render_partial_for_html(partial)
    render :partial => "/users/show/show", 
                       :layout => true, 
                       :locals => { :content_partial => partial }
  end

  def render_partial_for_js(partial)
    render :update do |page|
      page['sub-content-wrap'].replace_html :partial => partial
    end    
  end
  
  # Checks the visibility of a user
  def check_visibility
    raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)
  end  
  
  def find_user
    @user = User.find_by_permalink(params[:id])
  end
end
