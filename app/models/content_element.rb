# encoding: UTF-8
class ContentElement < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :element, :polymorphic => true
  belongs_to :container, :polymorphic => true
  
  acts_as_list :scope => :container
  
end
