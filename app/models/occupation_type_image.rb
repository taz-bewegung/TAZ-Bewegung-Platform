class OccupationTypeImage < ActiveRecord::Base
  
  belongs_to :occupation_type
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :path_prefix => 'public/uploads/occupation_types/', 
                  :max_size => 2.megabytes,
                  :thumbnails => { :tiny => '15x12', :small => '91x67'},
                  :processor => :MiniMagick
  
end
