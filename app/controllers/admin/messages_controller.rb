# encoding: UTF-8
class Admin::MessagesController < ApplicationController

  before_filter :setup
  before_filter :login_required

  ssl_required :new, :create, :reply, :index, :sent, :show, :destroy, :system

  def new
    @message = Message.new(params[:message])
    @message.sender = current_user
    respond_to do |format|
      format.html do 
        render :partial => "/admin/messages/new", 
               :layout => true
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => "/admin/messages/new"
        end
      end
    end
  end
  
  def create
    @message = Message.new(params[:message])
    @message.subject = "Kein Betreff" if @message.subject.blank?
    @message.sender_id = current_user.id
    if @message.validate_attributes :only => [:body]
      @message.send_system_messages(current_user)
      sent
    else
      respond_to do |format|
        format.html do 
          render :partial => "/admin/messages/new", :layout => true
        end
        format.js do 
          render :update do |page|
            page["sub-content"].replace_html :partial => "/admin/messages/new"
          end
        end
      end
    end
  end
  
  
  # Renders the standard index action. The parameter <tt>params[:page]</tt> is used for pagination.
  # The messages renders depending on the requeust format.
  def index
    @messages = Message.none_system_message.paginate(:all, :order => "messages.sent_at DESC", :page => params[:page], :per_page => 20)
    @sub_partial = "/admin/messages/inbox"    
    render_list
  end
  
  def sent
    @messages = current_user.sent_messages.grouped_by_conversation.paginate(:all, :page => params[:page], :per_page => 20)    
    @sub_partial = "/admin/messages/sent"
    render_list    
  end
  
  def deleted
    @messages = Message.only_deleted.paginate(:all, :page => params[:page], :per_page => 20)    
    @sub_partial = "/admin/messages/system"
    render_list    
  end  
    
  def destroy
    @message = Message.find(params[:id])
    @message.delete_for(current_user)
    
    render :update do |page|
      page["message_#{params[:id]}"].remove
    end
  end
  
  private
  
    def render_list
      respond_to do |format|
        format.html do 
          render :partial => "/admin/messages/index", 
                 :layout => true
        end
        format.js do 
          render :update do |page|
            page["sub-content"].replace_html :partial => @sub_partial
          end
        end
      end 
    end

  
    def authenticate_person
      @message = Message.find(params[:id])
      unless (@message.recipient_id==current_user.id ||
              @message.sender_id==current_user.id)
        redirect_to my_helpedia_path
      end
    end
    
    def setup #:doc
      @user = current_user if current_user.is_a?(User)
      @organisation = current_user if current_user.is_a?(Organisation)      
    end


end
