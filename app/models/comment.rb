# encoding: UTF-8
class Comment < ActiveRecord::Base
  include Gravtastic
  # Plugins
  is_gravtastic :with => :email 
  acts_as_paranoid
  
  after_create :create_feed  
  
  # Associations
  # belongs_to :post, :class_name => "BlogPost", :foreign_key => "blog_post_id"

  belongs_to :commentable, :polymorphic => true     # What to comment
  belongs_to :author, :polymorphic => true       # Who does it
    
  # Validations
  validates_presence_of :name, :body
  validates_with_hidden_captcha
  
  # Scopes
  #named_scope :visible, { :conditions => { :state => "visible" } }
  class << self
    def visible
      where(:state => "visible")
    end
  end
   
  # State machine
  acts_as_state_machine :initial => :visible
  state :visible
  state :hidden, :enter => :do_hide

  event :hide do
    transitions :from => :visible, :to => :hidden
  end  
  
  event :unhide do
    transitions :from => :hidden, :to => :visible
  end
  
  def do_hide; end
  
  ##
  # Methods
  
  # Set association to a author (user, organisation) and fill the required
  # name attribute.
  def set_author_values_for(user)
    self.author = user
    self.name = user.full_name
  end
  
  def create_feed
    self.notify_observers :comment_created
  end
  
end
