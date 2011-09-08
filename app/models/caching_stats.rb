class CachingStats < ActiveRecord::Base
  
  named_scope :with_key, lambda { |key|
    { :conditions => ["key = ?", key] }
  }  
  
  class << self
    #extend ActiveSupport::Memoizable
    
    def date_for_key(key)
      c = CachingStats.find_or_create_by_key(key)
      c.updated_at.to_s(:number)
    end
    #memoize :date_for_key     
    
    def update_key(key)
      c = CachingStats.find_or_create_by_key(key)
      c.update_attribute :updated_at, Time.now
    end
    
  end
  
end
