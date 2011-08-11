class DocumentAttachment < ActiveRecord::Base
  
  belongs_to :attachable, :polymorphic => true
  belongs_to :document
  
end
