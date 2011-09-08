class ContentElement < ActiveRecord::Base

  belongs_to :element, :polymorphic => true
  belongs_to :container, :polymorphic => true
  
  acts_as_list :scope => :container
  
end
