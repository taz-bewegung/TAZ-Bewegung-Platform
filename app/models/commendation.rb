class Commendation < ActiveRecord::Base

  # Filter
  before_create :send_notifications
  
  # Associations
  belongs_to :commendable, :polymorphic => true
  
  # Validations
  validates_presence_of :receiver_email
  validates_presence_of :sender_name
  validates_presence_of :sender_email
  validates_with_hidden_captcha  
  
                      
  validates_format_of :sender_email, 
                      :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i

#  apply_simple_captcha :message => "", :add_to_base => true                        
  
  protected
  
    def validate
      status = true      
      recipients = self.receiver_email.split(",")
      for receiver in recipients do
        status = false if(/^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i.match(receiver).nil?)       
      end
      errors.add("receiver_email", :email_list) unless status==true
      
    end
  
  
  private       
    def send_notifications
      self.receiver_email.split(",").each { |address| UserMailer.deliver_commendation(self, address) }
    end
      
end
