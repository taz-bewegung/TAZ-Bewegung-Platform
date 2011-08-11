class EventCategory < ActiveRecord::Base
  
  has_many :events
  
  def self.to_select_options
    find(:all).map { |f| [f.name, f.id] }
  end
  
  # Finder
  scope :available
end
