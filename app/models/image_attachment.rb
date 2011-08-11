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
class ImageAttachment < ActiveRecord::Base
  
  # Plugins
  acts_as_paranoid
  
  belongs_to :attachable, :polymorphic => true
  belongs_to :image
  
  ##
   # Constants

   NO_REPEAT = "no-repeat" unless defined? NO_REPEAT  
   REPEAT_X = "repeat-x" unless defined? REPEAT_X
   REPEAT_Y = "repeat-y" unless defined? REPEAT_Y
   REPEAT_XY = "repeat" unless defined? REPEAT_XY
   REPEAT_OPTIONS = [
                     ["Nicht wiederholen", NO_REPEAT],
                     ["Horizontal", REPEAT_X],
                     ["Vertikal", REPEAT_Y],
                     ["Horizontal & Vertikal", REPEAT_XY],                    
                    ] unless defined? REPEAT_OPTIONS

   HORIZONICAL_ALIGN_LEFT = "left" unless defined? HORIZONICAL_ALIGN_LEFT
   HORIZONICAL_ALIGN_RIGHT = "right" unless defined? HORIZONICAL_ALIGN_RIGHT
   HORIZONICAL_ALIGN_CENTER = "center" unless defined? HORIZONICAL_ALIGN_CENTER  
   HORIZONICAL_ALIGN_OPTIONS = [
                    ["Linksbündig", HORIZONICAL_ALIGN_LEFT],
                    ["Mittig", HORIZONICAL_ALIGN_CENTER],                   
                    ["Rechtsbündig", HORIZONICAL_ALIGN_RIGHT],
                   ] unless defined? HORIZONICAL_ALIGN_OPTIONS

   ##
   # Associations
   belongs_to :attachable, :polymorphic => true
   belongs_to :image

   attr_accessor :helpedia_id, :elargio_id, :temp_image

   def prepare
    self.image.find_or_create_thumbnail(self.size) if self.size.present?
    self.image.reload
    self 
   end

   def size
     return false if self.width.blank? and self.height.blank?
     self.height = self.width if self.height.blank?
     self.width = self.height if self.width.blank?
     "#{self.width}x#{self.height}"
   end
  
   
end
