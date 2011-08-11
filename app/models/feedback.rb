class Feedback < ActiveRecord::BaseWithoutTable

  column :name, :string
  column :email, :string
  column :message, :text
  column :type, :string
  column :url, :string


  validates_presence_of :message
  
#  apply_simple_captcha :message => "", :add_to_base => true                        
  
  def to_param
    "1"
  end  
  
end