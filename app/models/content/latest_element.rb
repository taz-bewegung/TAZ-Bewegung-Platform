# encoding: UTF-8
class Content::LatestElement < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  set_table_name :content_latest_elements 
  belongs_to :element, :polymorphic => true  
  
end
