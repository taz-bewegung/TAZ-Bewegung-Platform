# encoding: UTF-8
class Country < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  # Associations
  has_and_belongs_to_many :organisations
  
end
