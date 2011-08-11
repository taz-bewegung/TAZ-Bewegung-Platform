# -*- coding: utf-8 -*-
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
class NewsletterSubscriber < ActiveRecord::Base
  
  before_create :create_confirmation_code
  after_create :send_confirmation_email
    
  validates_uniqueness_of :email, :message => " ist bereits für den Newsletter registriert."
  validates_presence_of   :email  
  validates_format_of     :email, :with => /^[a-zA-Z0-9](([.[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/
  
  attr_accessor :confirmed_user
  
  # Use acts_as_state_machine for monitoring the state of a subscribtion.
  acts_as_state_machine :initial => :pending
  state :pending
  state :confirmed,  :enter => :do_confirm
  
  event :confirm do
    transitions :from => :pending, :to => :confirmed 
  end
  
  def do_confirm
    UserMailer.deliver_newsletter_subscribed(self)
  end  
  
  
  # Adds a new subscriber from an existing or already confirmed user.
  # Prevents from double opt-in.
  def self.create_for_confirmed_user(options = {})
    subscriber = NewsletterSubscriber.new(options)
    subscriber.confirmed_user = true
    subscriber.save_with_validation(false)
    subscriber.update_attribute :state, 'confirmed'
  end
  
  private    
  
    def create_confirmation_code
      self.confirmation_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
    end
    
    def send_confirmation_email
      UserMailer.deliver_confirm_newsletter(self) unless @confirmed_user      
    end
  
end
