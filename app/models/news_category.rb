# encoding: UTF-8
class NewsCategory < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  before_save :create_permalink

  has_many :news_memberships  
  has_many :news, :through => :news_memberships
  
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
