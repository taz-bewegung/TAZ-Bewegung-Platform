class LocationMembership < ActiveRecord::Base
  
  # Associations
  belongs_to :location
  belongs_to :member, :polymorphic => true
  
end
