# encoding: UTF-8
class BlogContentImage < ActiveRecord::Base
  
  has_many :blog_contents, :as => :contentable
  
end
