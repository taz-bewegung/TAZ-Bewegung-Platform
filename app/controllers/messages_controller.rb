# encoding: UTF-8
class MessagesController < ApplicationController

  before_filter :login_required, :only => [:new, :create]
  before_filter :find_association 
  
  ssl_allowed :recipients, :new, :create
 
  def new 
    @message = Message.new
    @message.sender = current_user
    @message.recipient_ids = [@user.id]
    @message.recipient_types = @user.class.to_s
    render :partial => "new"
  end
  
  def recipients
    users = current_user.friends.find :all, :conditions => [ "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", 
                                                             '%'+params[:q].to_s.downcase + '%', '%'+params[:q].to_s.downcase + '%' ],
                            :order => "first_name ASC",
                            :limit => 5
    render :json => users.map{ |user| { :value => user.id, :label => user.full_name} }
  end
  
  def create
    @message = Message.new(params[:message])
    @message.subject = "Kein Betreff" if @message.subject.blank?
    @message.sender = current_user
    @message.sent_at = Time.now
    @message.recipient_types = @user.class.to_s
    if @message.valid?
      @message.handle_multi_recipients
      render :action => :create
    else
      respond_to do |format|
        format.js do 
          render :update do |page|
            page["#nyroModalContent"].replace_html :partial => "new"
          end
        end
      end
    end    
  end
  
  
  def index
    raise ActionController::UnknownAction
  end
  
  private
    
  def find_association
    params.each do |name, value|
      if name =~ /(.+)_id$/
        @user =  $1.classify.constantize.find_by_permalink(value)
      end
    end
  end    
  
end
