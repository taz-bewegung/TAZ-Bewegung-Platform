class BlogContentText < ActiveRecord::Base
  
  attr_accessor :contentable_type  
  
  ##
  # Constants
  IMAGE_ALIGNMENT_TOP = "1" unless defined?(IMAGE_ALIGNMENT_TOP)
  IMAGE_ALIGNMENT_BOTTOM = "2" unless defined?(IMAGE_ALIGNMENT_BOTTOM)
  IMAGE_ALIGNMENT_IN_TEXT_LEFT = "3" unless defined?(IMAGE_ALIGNMENT_IN_TEXT_LEFT)
  IMAGE_ALIGNMENT_IN_TEXT_RIGHT = "4" unless defined?(IMAGE_ALIGNMENT_IN_TEXT_RIGHT)

  ALIGNMENT = [
      ['Bilder oben anordnen', IMAGE_ALIGNMENT_TOP], 
      ['Bilder unten anordnen', IMAGE_ALIGNMENT_BOTTOM], 
      ['Bilder im Text links anordnen', IMAGE_ALIGNMENT_IN_TEXT_LEFT],
      ['Bilder im Text rechts anordnen', IMAGE_ALIGNMENT_IN_TEXT_RIGHT]
   ] unless defined?(ALIGNMENT)
  
  ##
  # Plugins
  acts_as_paranoid
  
  ##
  # Associations
  has_one :blog_post_content, :as => :contentable
  has_many :image_attachments, :as => :attachable
  has_many :images, :through => :image_attachments
  
  accepts_nested_attributes_for :image_attachments, 
                                :allow_destroy => true  
  
end
