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
class BlogContentVideo < ActiveRecord::Base
  
  attr_accessor :contentable_type  

  #acts_as_video_fu
  
  has_one :blog_post_content, :as => :contentable
  
  validates_presence_of :video_url
  
  def validate
    unless video_url.blank?
      errors.add(:video_url, "darf keine Leerzeichen enthalten") if video_url.strip!
      errors.add(:video_url, "besitzt ein ungültiges Format") unless type
    end
  end
end
