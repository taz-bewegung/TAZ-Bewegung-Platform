# -*- coding: utf-8 -*-
=begin
  This file is part of bewegung.

  Bewegung is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Foobar is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with bewegung.  If not, see <http://www.gnu.org/licenses/>.
=end
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
