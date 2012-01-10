# encoding: UTF-8
class ActivityMembership < ActiveRecord::Base
  
  before_create :check_for_duplicate
  belongs_to :activity, :polymorphic => true
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  validates_length_of :message, :maximum => 140, :allow_blank => true
  validates_with_hidden_captcha  
  
  acts_as_state_machine :column => :state, :initial => :pending
  
  # Modules
  include Bewegung::Uuid
  
  # States
  state :pending
  state :active, :enter => :do_activate
  
  event :pending do 
    transitions :from => :canceled, :to => :pending
  end
  
  event :activate do
    transitions :from => :pending, :to => :active
  end    
  
  #named_scope :active, :conditions => ["state = 'active'"]
  #named_scope :active_with_user, :conditions => ["state = 'active' AND (SELECT users.state FROM users WHERE users.uuid = activity_memberships.user_id) = 'active'"]
  #named_scope :latest, :order => "created_at DESC"
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}
  #named_scope :pending, :conditions => ["state = 'pending'"]  
      
  def do_activate
  end
  
  private
      
    def check_for_duplicate
      if ActivityMembership.exists?(:activity_id => self.activity_id, :user_id => self.user_id) then
        false
      end
      
    end
  
end
