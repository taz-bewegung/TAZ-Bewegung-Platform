# encoding: UTF-8
class LocationCategoryMembership < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  # Associations
  belongs_to :location
  belongs_to :location_category
  
end
