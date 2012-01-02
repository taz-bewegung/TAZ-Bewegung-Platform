class Request
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  extend ActiveModel::Translation
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :message
  
  attr_accessor :name, :email, :message
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

   def persisted?
     false
   end
end