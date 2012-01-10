# encoding: UTF-8
class BlogContentHtml < ActiveRecord::Base
  
  attr_accessor :contentable_type  
  
  ##
  # Associations
  
  has_one :blog_post_content, :as => :contentable
  
  # Modules
  include Bewegung::Uuid
    
  ##
  # Plugins
  
  acts_as_paranoid  
  
end
