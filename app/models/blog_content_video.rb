class BlogContentVideo < ActiveRecord::Base
  
  attr_accessor :contentable_type  

  acts_as_video_fu
  
  has_one :blog_post_content, :as => :contentable
  
  validates_presence_of :video_url
  
  def validate
    unless video_url.blank?
      errors.add(:video_url, "darf keine Leerzeichen enthalten") if video_url.strip!
      errors.add(:video_url, "besitzt ein ungültiges Format") unless type
    end
  end
end
