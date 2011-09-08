# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  before_filter :check_for_user, :only => [:new, :create]
  
  ssl_required :new, :create, :forgot_password, :forget_password, :password_changed
  ssl_allowed :destroy

  # render new.rhtml
  def new
    @session = Session.new
  end

  def create
    logout_keeping_session!
    @session = Session.new(params[:session])   
    user = User.authenticate(params[:session][:email], params[:session][:password])
    user = Organisation.authenticate(params[:session][:email], params[:session][:password]) if user.nil?
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      user.log_login!

      if params[:session][:remember_me] == "1"      
        handle_remember_cookie! true
      end
      
      redirect_to my_helpedia_path
      #flash[:notice] = I18n.t(:"session.login.success")
    else
      @session.errors.add(['email'],' und Passwort stimmen nicht überein.')
      @session.errors.add(['password'],' und E-Mail-Adresse stimmen nicht überein.')
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = I18n.t(:"session.logout.success")
    redirect_back_or_default('/')
  end 
  
  # Forgot password
  def forgot_password
    @session = Session.new
  end
  
  def forget_password  
    params[:session] = [] if params[:session].blank?
    @session = Session.new(params[:session])       
    unless @session.forget_password_email.blank?
      user = User.find_by_email(@session.forget_password_email)
      if user.blank?
        user = Organisation.find(:first, :conditions => ["helpedia_contact_email = ? OR email = ? OR contact_email = ?", @session.forget_password_email, @session.forget_password_email, @session.forget_password_email])      
      end      
    end

    if user
      params[:session][:forget_password_email] = user.notify_email
      user.forgot_password!
    else
      @session.errors.add(['forget_password_email'],' ist nicht registriert.')
      render :action => "forgot_password"
    end    
  end 
  
  def reset_password
    @user = User.find_by_password_reset_code(params[:key])
    if @user.blank?
      @user = Organisation.find_by_password_reset_code(params[:key])
    end    
    raise ActiveRecord::RecordNotFound if @user.blank? or params[:key].blank?
  end 
  
  def change_password
    @user = User.find_by_password_reset_code(params[:key])
    if @user.blank?
      @user = Organisation.find_by_password_reset_code(params[:key])
      @user.attributes = params[:organisation]          
    else
      @user.attributes = params[:user]
    end
    
    @user.force_password_required = true
    
    if @user.validate_attributes(:only => [:password, :password_confirmation])
      
      @user.save_with_validation(false)
      @user.changed_password!      
      redirect_to password_changed_path
    else
      render :action => :reset_password
    end
  end
  
  def password_changed
  end
  
  def cancel_simulation
    reset_simulation
    redirect_to admin_path
  end  
  
protected

  def check_for_user
    redirect_back_or_default("/") if current_user
  end
  # Track failed login attempts
  def note_failed_signin
   # flash[:error] = I18n.t(:"session.login.error")    
   # logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
