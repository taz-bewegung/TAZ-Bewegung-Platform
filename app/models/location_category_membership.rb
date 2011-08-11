class LocationCategoryMembership < ActiveRecord::Base
  
  # Associations
  belongs_to :location
  belongs_to :location_category
  
end
