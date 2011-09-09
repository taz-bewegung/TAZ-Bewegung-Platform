class Session
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  extend ActiveModel::Translation
  extend ActiveModel::Callbacks
  
  attr_accessor :email, 
                :password,
                :type,
                :remember_me,
                :forget_password_email

  validates :password, :presence => true
  validates :email, :presence => true
  
  def attributes
    { :email => @name,
      :password => @email,
      :type => @message,
      :remember_me => @remember_me,
      :forget_password_email => @forget_password_email
     }
  end
  
  def persisted?
    false
  end

end