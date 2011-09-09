# encoding: UTF-8
class Content::WelcomePageTeaserImage < ActiveRecord::Base
  
  set_table_name "content_welcome_page_teaser_images"
  
  belongs_to :teaser, :class_name => "Content:WelcomePageTeaser", :foreign_key => "content_welcome_page_teaser_id"
  
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :path_prefix => 'public/uploads/content-images/', 
                  :max_size => 4.megabytes,
                  :thumbnails => { :teaser => "100x130c", :icon => "20x26c" },
                  :processor => :Rmagick,
                  :uuid_primary_key => true
  
end
