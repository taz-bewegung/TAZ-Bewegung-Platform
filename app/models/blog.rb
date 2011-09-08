class Blog < ActiveRecord::Base
  
  # Associations
  belongs_to :bloggable, :polymorphic => true
  has_many :posts, :class_name => 'BlogPost'
  
  # Plugins
  acts_as_tagger
  
end
