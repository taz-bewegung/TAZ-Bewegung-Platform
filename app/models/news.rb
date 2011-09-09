# encoding: UTF-8
class News < ActiveRecord::Base
  
  before_save :create_permalink

  has_many :news_memberships
  has_many :news_categories, :through => :news_memberships
  belongs_to :author, :class_name => "User", :foreign_key => :created_by 

  has_one :image, :through => :image_attachment
  has_one :image_attachment, :as => :attachable 
  has_one :document, :through => :document_attachment
  has_one :document_attachment, :as => :attachable  
  
  def temp_id
    self.id || "0"
  end 
  
  attr_accessor :temp_image, :temp_document
    
  private
  
    def create_permalink
      temp_permalink = self.title.to_permalink
      count = News.count :conditions => ["permalink LIKE ? AND uuid != ?", "#{temp_permalink}%", self.id]
      if count == 0
        self.permalink = temp_permalink.to_permalink 
      else
        self.permalink = "#{temp_permalink}-#{(count.to_i + 1).to_s}".to_permalink 
      end      
    end
  

end
