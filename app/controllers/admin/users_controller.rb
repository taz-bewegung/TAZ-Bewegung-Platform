# encoding: UTF-8
class Admin::UsersController < ApplicationController

  layout 'admin'
  before_filter :setup
  before_filter :find_user, :only => [:simulate, :suspend, :suspend_confirmation, :reactivate, 
                                      :update_comment, :edit, :update, :destroy_confirmation, :destroy]
  ssl_required :index, :suspended, :activate, :reactivate, :suspend, :update, :edit,
               :update_comment, :suspend_confirmation, :destroy, :destroy_confirmation, :statistics, :simulate
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'  
  
  # Collection methods
  
  def index
    @search = Search::Admin::User.new(params[:search_admin_user])
    @search.add_condition(["users.state = 'active'"])    
    @users = @search.search(params[:page])
    @path = admin_users_path
  end
  
  def suspended
    @search = Search::Admin::User.new(params[:search_admin_user])
    @search.add_condition(["users.state = 'suspended'"])
    @users = @search.search(params[:page])
    @path = suspended_admin_users_path
  end

  
  def statistics
  end 
  
  def edit
  end
  
  def update
    @user.attributes = params[:user]
    if @user.save
      redirect_to admin_users_path
    else
      render :action => :edit
    end
  end
  
  def simulate
    simulate_user(@user)
    redirect_to my_helpedia_path
  end
  
  def suspend_confirmation
    @message = Message.new :subject => t(:"system_message.user.suspend.subject", :title => h(@user.full_name)),
                           :body => t(:"system_message.user.suspend.message")    
  end
  
  def suspend
    message = Message.new(params[:message])
    message.attributes = { :sender => current_user,
                           :recipient => @user,
                           :system_message => true }
    message.deliver
    @user.suspend!
    render :update do |page|
      page << 'window.location.href="' + admin_users_path + '"' 
    end
  end  
  
  def destroy_confirmation
    @message = Message.new :subject => t(:"system_message.user.destroy.subject", :title => h(@user.full_name)),
                           :body => t(:"system_message.user.destroy.message")
  end
  
  def destroy
    message = Message.new(params[:message])
    # TODO Send message via email
    @user.destroy
    render :update do |page|
      page << "$.nyroModalRemove();" 
      page[@user].remove
    end    
  end
  
   
  
  def update_comment
    @user.update_attribute(:admin_comment, params[:value])
    render :text => @user.admin_comment
  end  
  
  private
  
    def find_user
      @user = User.find_by_permalink params[:id]
    end

    def setup
      params[:search_admin_user] = {} if params[:search_admin_user].blank?
    end
  
end
