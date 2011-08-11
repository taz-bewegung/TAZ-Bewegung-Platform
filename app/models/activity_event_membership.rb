class ActivityEventMembership < ActiveRecord::Base
  
  attr_accessor :event_id_autocomplete
  attr_accessor :activity_id_autocomplete
    
  def validate
    if self.event_id.blank? or ActivityEventMembership.exists?(:event_id => self.event.id, :activity_id => self.activity_id)
      errors.add(:event_id_autocomplete, " ist nicht korrekt ausgefüllt. Du kannst nur Termine angeben, die in der Liste erscheinen.") 
    end
  end

  belongs_to :event
  belongs_to :activity
  
  def temp_id
    self.id || "0"
  end
  
end
