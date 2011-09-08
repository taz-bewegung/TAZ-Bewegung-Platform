class MyHelpedia::FriendshipsController < ApplicationController
  
  before_filter :login_required
  before_filter :user_login_required
  before_filter :find_user, :setup
  
  ssl_required :index, :view, :destroy, :deny, :accept
  
  def index
    case params[:state]
    when "requested"
      @friendships = current_user.friendships.requested.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends_to_accept
    when "pending"
      @friendships = current_user.friendships.pending.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends_pending
    else
      @friendships = current_user.friendships.accepted_with_user.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends
    end
    
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/friendships/index" }
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => "/my_helpedia/friendships/friendships"
        end
      end
    end
  end
  
  def view
    case params[:state]
    when "requested"
      @friendships = current_user.friendships.requested.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends_to_accept
    when "pending"
      @friendships = current_user.friendships.pending.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends_pending
    else
      @friendships = current_user.friendships.accepted_with_user.paginate(:all, :page => params[:page], :include => [:friend, :user] )
      @active = :friends
    end
    respond_to do |format|
       format.html do
         render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show", 
                :layout => true, :locals => { :content_partial => "/my_helpedia/friendships/index" }
       end    
       format.js do
         render :update do |page|
           page["sub-content-list"].replace_html :partial => "/my_helpedia/friendships/list_#{params[:list_type]}", 
                                                 :locals => { :friendships => @friendships }   
         end
       end
    end
  end
  
  def destroy
    @friendship = Friendship.find(params[:id])
    @opposed_friendship = Friendship.find_by_user_id_and_friend_id(@friendship.friend_id, @friendship.user_id)
    @opposed_friendship.delete
    @friendship.delete
    render :update do |page|
      page["separator-friendship_#{params[:id]}"].remove
      page["friendship_#{params[:id]}"].remove
      page["#sub-content-list"].replace_html :text => "Keine Datensätze vorhanden." if current_user.friendships.accepted.count.to_i < 1
    end
  end
  
  def deny
    @friendship = Friendship.find(params[:id])
    @opposed_friendship = Friendship.find_by_user_id_and_friend_id(@friendship.friend_id, @friendship.user_id)
    @opposed_friendship.delete
    @friendship.delete
    render :update do |page| 
      page["separator-friendship_#{params[:id]}"].remove            
      page["friendship_#{params[:id]}"].remove
      
      #Apple Icon
      page["#friendships span.tab-icon"].replace_html :text => current_user.friendships.requested.count.to_i
      page["span.tab-icon.requested"].replace_html :text => current_user.friendships.requested.count.to_i
      page["#friendships span.tab-icon"].hide unless current_user.friendships.requested.count.to_i > 0
      page["span.tab-icon.requested"].hide unless current_user.friendships.requested.count.to_i > 0
      
      page["#sub-content-list"].replace_html :text => "Keine Datensätze vorhanden." if current_user.friendships.requested.count.to_i < 1
    end
  end
  
  def accept
    @friendship = Friendship.find(params[:id])
    @friendship.accept!
    
    @friendship = Friendship.find_by_user_id_and_friend_id(@friendship.friend_id,@friendship.user_id)
    @friendship.accept!
    
    render :update do |page|
      page["separator-friendship_#{params[:id]}"].remove
      page["friendship_#{params[:id]}"].remove
      
      #Apple Icon
      page["#friendships span.tab-icon"].replace_html :text => current_user.friendships.requested.count.to_i
      page["span.tab-icon.requested"].replace_html :text => current_user.friendships.requested.count.to_i
      page["#friendships span.tab-icon"].hide unless current_user.friendships.requested.count.to_i > 0
      page["span.tab-icon.requested"].hide unless current_user.friendships.requested.count.to_i > 0
      
      page["#sub-content-list"].replace_html :text => "Keine Datensätze vorhanden." if current_user.friendships.requested.count.to_i < 1
    end
  end

  private
  
    def setup
      @template.main_menu :my_helpedia 
      params[:list_type] ||= "cards"
    end

    def render_index_for(type, list_title = nil)
        respond_to do |format|
           format.html do
             render :partial => "/my_helpedia/#{type}/show/show", :layout => true,
                                                                  :locals => { :content_partial => "/my_helpedia/friendships/index" }
           end    
           format.js do
             render :update do |page|
               page["sub-content"].replace_html :partial => "/my_helpedia/friendships/list_#{@list_type}"
               page[params[:spinner]].toggle
             end
           end
        end      
    end
  
    def find_user
      @user = current_user
    end
  
end
