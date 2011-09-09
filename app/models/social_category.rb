# encoding: UTF-8
class SocialCategory < ActiveRecord::Base 
  
#  self.skip_time_zone_conversion_for_attributes=[]
  
  before_create :generate_unique_permalink  

  has_many :social_category_memberships, :dependent => :destroy
  has_many :organisations,
    :through => :social_category_memberships,
    :source_type => "Organisation",
    :source => :member,
    :uniq => true   
  has_many :events, 
    :through => :social_category_memberships,
    :source_type => "Event",
    :source => :member,
    :uniq => true
  has_many :activities, 
    :through => :social_category_memberships,
    :source_type => "Activity",
    :source => :member,
    :uniq => true

  def self.to_select_options_with_permalink
    find(:all).map { |f| [f.title, f.permalink] }
  end    
  
  def self.to_select_options
    find(:all).map { |f| [f.title, f.id] }
  end  
  
  def to_param
    permalink
  end

  def generate_unique_permalink
   temp = self.title.to_permalink
   count = SocialCategory.count :conditions => ["permalink LIKE ?", "#{temp}%"]
   if count == 0
     self.permalink = temp.to_permalink 
   else
     self.permalink = "#{temp}-#{(count.to_i + 1).to_s}".to_permalink 
   end    
  end
  
  def api_hash
    hash = ActiveSupport::OrderedHash.new
    hash[:uuid] = self.uuid
    hash[:name] = self.title
    hash
  end 
    
  def to_json(options = {}) 
    api_hash.to_json
  end  
  
end
