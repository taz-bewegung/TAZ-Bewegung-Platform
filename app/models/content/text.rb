# encoding: UTF-8
class Content::Text < ActiveRecord::Base
  
  set_table_name "content_texts"
  
  has_one :content, :as => :element
  
  has_many :image_attachments, :as => :attachable
  has_many :images, :through => :image_attachments
  
end
