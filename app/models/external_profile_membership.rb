# encoding: UTF-8
class ExternalProfileMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :external_profile
  before_save :fix_url
  
  validates_presence_of :external_profile
  validates_presence_of :url
  
  def temp_id
    self.id || "0"
  end
  
  def fix_url
    protocol = self.url.include?("http") ? "" : "http://"
    self.url = "#{protocol}#{self.url}"
  end
    
end
