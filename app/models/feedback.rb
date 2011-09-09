# encoding: UTF-8
class Feedback
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  extend ActiveModel::Translation
  extend ActiveModel::Callbacks
  validates :message, :presence => true
  
  def attributes
    {
      :name => @name,
      :email => @email,
      :message => @message,
      :type => @string,
      :url => @url
    }
  end

  def to_param
    "1"
  end

  def persisted?
    false
  end

end