# encoding: UTF-8
class BlogContentImage < ActiveRecord::Base
  
  has_many :blog_contents, :as => :contentable
  
  # Modules
  include Bewegung::Uuid
  
end
