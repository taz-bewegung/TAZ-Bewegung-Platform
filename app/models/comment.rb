=begin
  This file is part of bewegung.

  Bewegung is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Foobar is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with bewegung.  If not, see <http://www.gnu.org/licenses/>.
=end
class Comment < ActiveRecord::Base
  include Gravtastic
  gravtastic
  
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
  #validates_with_hidden_captcha
  
  # Scopes
  scope :visible, { :conditions => { :state => "visible" } }
   
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
