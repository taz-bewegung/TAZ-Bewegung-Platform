# encoding: UTF-8
class PageView < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :viewable, :polymorphic => true
  
end
