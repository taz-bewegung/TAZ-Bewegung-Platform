class MyHelpedia::UsersController < ApplicationController

  before_filter :find_user
  before_filter :setup 
  before_filter :login_required
  before_filter :user_login_required
  ssl_required :edit, :show, :update, :edit_part, :cancel_edit_part, :destroy, :destroy_confirmation
  uses_tiny_mce :only => :edit, :options => TAZ_TINY_MCE_OPTIONS
    
  def show
    redirect_to edit_my_helpedia_user_path(@user)
    #respond_to do |format|
    #  format.html { render_partial_for_html("/my_helpedia/users/show/overview") } 
    #  format.js { render_partial_for_js("/my_helpedia/users/show/overview") }       
    #end    
  end
  
  def edit
    respond_to do |format|
      format.html { render_partial_for_html("/my_helpedia/users/edit/edit") } 
      format.js { render_partial_for_js("/my_helpedia/users/edit/edit") }       
    end    
  end
  
  def cancel_edit_part
    render :update do |page|
      page[params['part']].replace :partial => "/my_helpedia/users/edit/#{params['part']}"
    end
  end
  
  def edit_part
    render :update do |page|
      page[params['part']].replace :partial => "/my_helpedia/users/edit/edit_#{params['part']}"
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"   
    end    
  end 
  
  def destroy
    current_user.destroy
    reset_session
    render :update do |page|
      page << "window.location.href='#{root_url}'" 
    end
  end
  
  def update    
    # Save image if delivered
    unless params[:image].blank?
      @user.image = Image.find(params[:image])
    end

    @user.attributes = params[:user]
    
    unless params[:address].nil?
      @user.address.attributes = params[:address]
    end
    if @user.valid?
      
      # Log changes
      if @user.changed?
        UserChangeEvent.create :trigger => @user, :operator => @user, :changes => @user.changes
      end
      
      # Finally save
      @user.save
      unless params[:address].nil?
        @user.address.save(false)
      end
        
      render :update do |page|
        page[params['part']].replace_html :partial => "/my_helpedia/users/edit/#{params['part']}"
      end    
    else
      render :update do |page|
        page[params['part']].replace_html :partial => "/my_helpedia/users/edit/edit_#{params['part']}"
        page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"        
      end      
    end
  end
  
  private 
  
    def render_partial_for_html(partial)
      render :partial => "/my_helpedia/users/show/show", 
                         :layout => true, 
                         :locals => { :content_partial => partial }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end    
    end
    
    def find_user
      @user = current_user
    end
    
    def setup
      @template.main_menu :my_helpedia
    end    
    
end
