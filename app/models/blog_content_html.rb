class BlogContentHtml < ActiveRecord::Base
  
  attr_accessor :contentable_type  
  
  ##
  # Associations
  
  has_one :blog_post_content, :as => :contentable
    
  ##
  # Plugins
  
  acts_as_paranoid  
  
end
