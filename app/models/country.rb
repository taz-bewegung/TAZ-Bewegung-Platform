class Country < ActiveRecord::Base
  
  # Associations
  has_and_belongs_to_many :organisations
  
end
