# encoding: UTF-8
class SocialCategoryImage < ActiveRecord::Base 

  # Modules
  include Bewegung::Uuid

  belongs_to :social_category

  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :path_prefix => 'public/uploads/organisation_categories/', 
                  :max_size => 2.megabytes,
                  :thumbnails => { :tiny => '15x12', :small => '91x67'},
                  :processor => :MiniMagick
end
