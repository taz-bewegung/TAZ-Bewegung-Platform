# encoding: UTF-8
class LocationCategoryMembership < ActiveRecord::Base
  
  # Associations
  belongs_to :location
  belongs_to :location_category
  
end
