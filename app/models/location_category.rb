class LocationCategory < ActiveRecord::Base
  
  before_create :generate_unique_permalink  
  
  # Associations
  has_many :location_category_memberships
  has_many :locations, :through => :location_category_memberships
  
  def self.to_select_options
    find(:all, :order => "name ASC").map { |f| [f.name, f.id] }
  end
  
  
  private
  
    def generate_unique_permalink
      count = LocationCategory.count :conditions => ["permalink LIKE ?", "#{self.name.to_permalink}%"]
      if count == 0
        self.permalink = self.name.to_permalink 
      else
        self.permalink = "#{self.name}-#{(count.to_i + 1).to_s}".to_permalink 
      end    
    end  
  
end
