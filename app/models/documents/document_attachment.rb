# encoding: UTF-8
class DocumentAttachment < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :attachable, :polymorphic => true
  belongs_to :document
  
end
