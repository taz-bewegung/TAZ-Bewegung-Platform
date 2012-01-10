# encoding: UTF-8
class DailyId < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  class << self
    
    # Creates a uniqe integer for a specific date
    def generate
      
      # Find or create record
      daily_id = DailyId.find_or_create_by_created_on(Date.today)
      id = daily_id.daily_id 
      daily_id.update_attribute(:daily_id, (id+1))
      
      return id || 1     # Return the current id of 1
    end
    
  end
  
end
