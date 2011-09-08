class FriendshipsController < ApplicationController
  
  before_filter :login_required, :only => [:create, :destroy]
  before_filter :user_login_required, :only => [:create, :destroy]

  def create
    user = User.find_by_permalink(params[:user_id])
    friend = current_user 
    # Delegate to model (skinny controllers, fat models)
    @friendship = Friendship.create_for(user, current_user)
    flash[:notice] = "#{user.full_name} wurde über deine Freundesanfrage benachrichtigt."
    render :update do |page|
      page << "$.nyroModalManual(
  		{
   			bgColor: '#000000',
   			content: '#{ render(:partial => "/friendships/created").gsub("\n", '\ \n') }',
   			type: 'content',
   			width: 560,
   			height: 150
  		});
  		"
    end
    
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    @opposed_friendship = Friendship.friendship_for_users(@friendship.friend_id, @friendship.user_id)
    
    # Deletion should be run in the model to.
    @opposed_friendship.delete
    @friendship.delete

    flash[:notice] = "AktivistIn wurde entfernt"
    redirect_to user_path(params[:user_id])
  end

  def index
    @user = User.find_by_permalink(params[:user_id])
    raise ActiveRecord::RecordNotFound if @user.blank?
    raise Helpedia::ItemNotVisible unless @user.visible_for?(current_user)    
    @friendships = @user.friendships.accepted_with_user.find( :all, :include => [:friend, :user] )
  end

end
