class MyHelpedia::BlogMessagesController < ApplicationController

  before_filter :find_association
  before_filter :setup
  before_filter :login_required
  
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :destroy  

  def index
    index_for_activity unless params[:activity_id].blank?
    index_for_organisation unless params[:organisation_id].blank?
  end 
  
  def new 
    new_for_activity unless params[:activity_id].blank?
    new_for_organisation unless params[:organisation_id].blank?
  end
  
  def edit
    edit_for_activity unless params[:activity_id].blank?
    edit_for_organisation unless params[:organisation_id].blank?    
  end
    
  def create
    create_for_activity unless params[:activity_id].blank?
    create_for_organisation unless params[:organisation_id].blank?    
  end
  
  def cancel_edit_part
    cancel_edit_part_for_activity unless params[:activity_id].blank?
    cancel_edit_part_for_organisation unless params[:organisation_id].blank?    
  end 
  
  def update
    update_for_activity unless params[:activity_id].blank?
    update_for_organisation unless params[:organisation_id].blank?    
  end
      
  def destroy
    blog_message = @activity.blog_messages.find(params[:id]) unless @activity.blank?
    blog_message = @organisation.blog_messages.find(params[:id]) unless @organisation.blank?    
    blog_message.destroy
    render :update do |page|
      page[params[:part]].remove
    end    
  end
  
  private     
    
    # New actions
    def new_for_activity
      @blog_message = @activity.blog_messages.new
      @form_url = my_helpedia_activity_blog_messages_path(@activity, :part => @blog_message.object_id)
      render :update do |page|
        page.insert_html :after, 'new_message', :partial => "/my_helpedia/blog_messages/index/activities/form"
        page << "$('##{params[:spinner]}').toggle();"        
      end      
    end
    
    def new_for_organisation
      @blog_message = @organisation.blog_messages.new
      @form_url = my_helpedia_organisation_blog_messages_path(@organisation, :part => @blog_message.object_id)
      render :update do |page|
        page.insert_html :after, 'new_message', :partial => "/my_helpedia/blog_messages/index/organisations/form"
        page << "$('##{params[:spinner]}').toggle();"                
      end      
    end
    
    # Edit actions
    def edit_for_activity
      @blog_message = @activity.blog_messages.find(params[:id])    
      @form_url = my_helpedia_activity_blog_message_path(@activity, @blog_message, :part => @blog_message.object_id)
      render :update do |page|
        page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/form"
        page << "$('##{params[:spinner]}').toggle();"                
      end    
    end        
    
    def edit_for_organisation
      @blog_message = @organisation.blog_messages.find(params[:id])    
      @form_url = my_helpedia_organisation_blog_message_path(@organisation, @blog_message, :part => @blog_message.object_id)
      render :update do |page|
        page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/form"
        page << "$('##{params[:spinner]}').toggle();"                
      end    
    end    
    
    # Create actions
    def create_for_activity
      @blog_message = @activity.blog_messages.new(params[:blog_message])
      @form_url = my_helpedia_activity_blog_messages_path(@activity, :part => @blog_message.object_id)    
      if @blog_message.save    
        if params[:image]
          @blog_message.image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/item", :locals => { :message => @blog_message }
        end
      else
        if params[:image]
          @blog_message.temp_image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/form"
        end      
      end
    end    
    
    def create_for_organisation
      @blog_message = @organisation.blog_messages.new(params[:blog_message])
      @form_url = my_helpedia_organisation_blog_messages_path(@organisation, :part => @blog_message.object_id)    
      if @blog_message.save    
        if params[:image]
          @blog_message.image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/item", :locals => { :message => @blog_message }
        end
      else
        if params[:image]
          @blog_message.temp_image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/form"
        end      
      end
    end
    
    # Cancel edit part    
    def cancel_edit_part_for_organisation
      if params[:id] != "0"
        @blog_message = @organisation.blog_messages.find(params[:id]) 
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/item", :locals => { :message => @blog_message }
        end    
      else
        render :update do |page|
          page[params[:part]].remove
        end      
      end
    end    

    def cancel_edit_part_for_activity
      if params[:id] != "0"
        @blog_message = @activity.blog_messages.find(params[:id]) 
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/item", :locals => { :message => @blog_message }
        end    
      else
        render :update do |page|
          page[params[:part]].remove
        end      
      end
    end
    
    # Update
    def update_for_activity
      @blog_message = @activity.blog_messages.find(params[:id]) 
      @form_url = my_helpedia_activity_blog_message_path(@activity, @blog_message, :part => @blog_message.object_id)            
      if @blog_message.update_attributes(params[:blog_message])
        if params[:image]
          @blog_message.image = Image.find(params[:image])
        end          
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/item", :locals => { :message => @blog_message }
        end
      else
        if params[:image]
          @blog_message.temp_image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/activities/form"
        end      
      end    
    end
    
    def update_for_organisation
      @blog_message = @organisation.blog_messages.find(params[:id]) 
      @form_url = my_helpedia_organisation_blog_message_path(@organisation, @blog_message, :part => @blog_message.object_id)            
      if @blog_message.update_attributes(params[:blog_message])
        if params[:image]
          @blog_message.image = Image.find(params[:image])
        end          
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/item", :locals => { :message => @blog_message }
        end
      else
        if params[:image]
          @blog_message.temp_image = Image.find(params[:image])
        end      
        render :update do |page|
          page[params[:part]].replace :partial => "/my_helpedia/blog_messages/index/organisations/form"
        end      
      end    
    end        
    
    ###
    # Rendering for various "index" actions (organisation/user)´
    ### 
  
    def index_for_activity
      @blog_messages = @activity.blog_messages
      render_index_for("activities")
    end
    
    def index_for_organisation
      @blog_messages = @organisation.blog_messages
      render_index_for("organisations")
    end     
        
    def render_index_for(type, title = nil)
      respond_to do |format|
         format.html do
           render :partial => "/my_helpedia/#{type}/show/show", :layout => true, 
                                                                :locals => { :content_partial => "/my_helpedia/blog_messages/index/#{type}/show" }
         end    
         format.js do
           render :update do |page|             
             page["sub-content-list"].replace_html :partial => "/my_helpedia/blog_messages/index/#{type}/list_#{params[:list_type]}", 
                                              :locals => { :blog_messages => @blog_messages, 
                                                           :list_title => title }    
           end
         end
      end      
    end 

    def find_association
      @user = current_user
      @organisation = current_user if current_user.is_a?(Organisation)
      @activity = @user.activities.find_by_permalink(params[:activity_id], :include => :blog_messages)      
    end
  
    def setup
      @template.main_menu :my_helpedia        
    end
  
  
end
