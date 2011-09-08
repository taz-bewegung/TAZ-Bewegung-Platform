# This Controller is for managing the messages of a user or organsation in his/its private area.

class MyHelpedia::MessagesController < ApplicationController
  
  before_filter :setup
  before_filter :login_required
  before_filter :authenticate_person, :only => :show
  
  ssl_required :new, :create, :reply, :index, :sent, :show, :destroy, :system
  
  def new
    @message = Message.new(params[:message])
    @message.sender = current_user
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/messages/new" }      
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => "/my_helpedia/messages/new"
        end
      end
    end
  end
  
  def create
    @message = Message.new(params[:message])
    @message.subject = "Kein Betreff" if @message.subject.blank?
    @message.sender = current_user
    @message.recipient_types = current_user.class.to_s
    if @message.valid?
      @message.handle_multi_recipients
      sent
    else
      respond_to do |format|
        format.html do 
          render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
                 :layout => true, :locals => { :content_partial => "/my_helpedia/messages/new" }
        end
        format.js do 
          render :update do |page|
            page["sub-content"].replace_html :partial => "/my_helpedia/messages/new"
          end
        end
      end
    end
  end
  
  def reply
    @response = Message.new(params[:message])
    @message = Message.find(params[:id])
    @response.sender = current_user
    @response.is_reply_to(@message)
    @response.conversation_id = @message.conversation_id
    if @response.save
      render :update do |page|
        page.insert_html :bottom, "message-table-show", :partial => "/my_helpedia/messages/full_message", :locals => { :message => @response }
        @response = Message.new        
        page["reply_form"].replace_html :partial => "/my_helpedia/messages/reply_form"
        page["spinner"].hide
      end
    else
      render :update do |page|
        page["reply_form"].replace_html :partial => "/my_helpedia/messages/reply_form"
        page["spinner"].hide        
      end        
    end
  end
  
  # Renders the standard index action. The parameter <tt>params[:page]</tt> is used for pagination.
  # The messages renders depending on the requeust format.
  def index
    @messages = current_user.received_messages.grouped_by_conversation.paginate(:all, :page => params[:page], :per_page => 10)
    @sub_partial = "/my_helpedia/messages/inbox"    
    render_list
  end
  
  def sent
    @messages = current_user.sent_messages.grouped_by_conversation.paginate(:all, :page => params[:page], :per_page => 10)    
    @sub_partial = "/my_helpedia/messages/sent"
    render_list    
  end
  
  def system
    @messages = current_user.system_messages.grouped_by_conversation.paginate(:all, :page => params[:page], :per_page => 10)    
    @sub_partial = "/my_helpedia/messages/system"
    render_list    
  end  
  
  
  def show
    @sub_partial = "show"  
    @message = Message.find(params[:id])
    @response = Message.new
    
    # Find all messages to a conversation
    @messages = Message.for_conversation(@message.conversation_id)
    for message in @messages
      message.mark_as_read if current_user == message.recipient
    end
   
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/messages/show" }      
      end
      format.js do 
        render :update do |page|
          page["#messages span.tab-icon"].replace_html :text => current_user.all_received_messages.unread.count.to_i
          page["#messages span.tab-icon.received"].replace_html :text => current_user.received_messages.unread.count.to_i
          page["#messages span.tab-icon.system"].replace_html :text => current_user.system_messages.unread.count.to_i
          
          page["#messages span.tab-icon"].hide unless current_user.all_received_messages.unread.count.to_i >=1
          page["#messages span.tab-icon.received"].hide unless current_user.received_messages.unread.count >=1
          page["#messages span.tab-icon.system"].hide unless current_user.system_messages.unread.count.to_i >=1
          
          page["sub-content"].replace_html :partial => "/my_helpedia/messages/show"
        end
      end
    end
  end
  
  
  def destroy
    @message = Message.find(params[:id])
    @message.delete_for(current_user)
    
    render :update do |page|
      page["message_#{params[:id]}"].remove
      page["separator-message_#{params[:id]}"].remove
      page["#messages span.tab-icon"].replace_html :text => current_user.all_received_messages.unread.count
      
    end
  end
  
  private
  
    def render_list
      respond_to do |format|
        format.html do 
          render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
                 :layout => true, :locals => { :content_partial => "/my_helpedia/messages/index" }      
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