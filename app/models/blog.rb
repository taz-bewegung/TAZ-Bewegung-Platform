# encoding: UTF-8
class Blog < ActiveRecord::Base
  
  # Associations
  belongs_to :bloggable, :polymorphic => true
  has_many :posts, :class_name => 'BlogPost'
  
  # Modules
  include Bewegung::Uuid
  
  # Plugins
  acts_as_tagger
  
end
