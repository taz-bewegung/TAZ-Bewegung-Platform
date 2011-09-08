class BlogContentImage < ActiveRecord::Base
  
  has_many :blog_contents, :as => :contentable
  
end
