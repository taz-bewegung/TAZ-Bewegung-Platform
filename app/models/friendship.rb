class Friendship < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :friend, :class_name => "User"
  
  # Scopes
  named_scope :pending, { :conditions => "friendships.state = 'pending'" }
  named_scope :requested, { :conditions => "friendships.state = 'requested'" }
  named_scope :accepted, { :conditions => "friendships.state = 'accepted'" }
  named_scope :accepted_with_user, { :conditions => "friendships.state = 'accepted' AND (SELECT users.state FROM users WHERE users.uuid = friendships.friend_id) = 'active'" }
  
  ##
  # Acts as state machine
  acts_as_state_machine :initial => :requested
  state :requested
  state :pending
  state :accepted, :enter => :do_accept
  
  event :pend do
    transitions :from => :requested, :to => :pending
  end
  
  event :accept do
    transitions :from => [:pending, :requested], :to => :accepted
  end 
  
  def do_accept
    self.updated_at = Time.now 
  end  
  
  
  def is_accepted?
    self.state == "accepted"
  end
  
  def is_requested?
    self.state == "requested"
  end
  
  def is_pending?
    self.state == "pending"
  end
  
  class << self  
    
  
    def friendship_for_users(user, friend)
      Friendship.find_by_user_id_and_friend_id(user,User.find(friend))  
    end
    
    # Creates a friendship in both directions for two users.
    def create_for(user, friend)
      # First check, if the friendship already exsits or the users are equal
      if user == friend or not Friendship.friendship_for_users(user.id, friend.id).blank?
        return nil
      end
      friendship_2 = nil
      # Create the friendship in a transaction
      transaction do
        friendship_1 = create(:user => user, :friend => friend, :user_type => "User")
        UserMailer.deliver_friendship_request(friendship_1)
        
        friendship_2 = create(:friend => user, :user => friend, :user_type => "User")
        friendship_2.pend!
      end
      friendship_2
    end

  end
  
end
