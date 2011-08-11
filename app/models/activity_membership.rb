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
class ActivityMembership < ActiveRecord::Base
  
  before_create :check_for_duplicate
  belongs_to :activity, :polymorphic => true
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  validates_length_of :message, :maximum => 140, :allow_blank => true
  #validates_with_hidden_captcha  
  
  acts_as_state_machine :column => :state, :initial => :pending
  
  # States
  state :pending
  state :active, :enter => :do_activate
  
  event :pending do 
    transitions :from => :canceled, :to => :pending
  end
  
  event :activate do
    transitions :from => :pending, :to => :active
  end    
  
  scope :active, :conditions => ["state = 'active'"]
  scope :active_with_user, :conditions => ["state = 'active' AND (SELECT users.state FROM users WHERE users.uuid = activity_memberships.user_id) = 'active'"]
  scope :latest, :order => "created_at DESC"
  scope :limit, lambda { |*num|
    { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  }
  scope :pending, :conditions => ["state = 'pending'"]  
      
  def do_activate
  end
  
  private
      
    def check_for_duplicate
      if ActivityMembership.exists?(:activity_id => self.activity_id, :user_id => self.user_id) then
        false
      end
      
    end
  
end
