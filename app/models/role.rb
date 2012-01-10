# encoding: UTF-8
class Role < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  has_and_belongs_to_many :users  

end