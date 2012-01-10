# encoding: UTF-8
class LocationMembership < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  # Associations
  belongs_to :location
  belongs_to :member, :polymorphic => true
  
end
