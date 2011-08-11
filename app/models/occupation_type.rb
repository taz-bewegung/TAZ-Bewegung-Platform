class OccupationType < ActiveRecord::Base
  
  has_many :jobs
  has_many :engagements  
  has_one :image, :class_name => "OccupationTypeImage"
  
  def self.to_select_options
    find(:all).map { |f| [f.name, f.id] }
  end  
  
  named_scope :available
  
end
