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
class Content::TopElement < ActiveRecord::Base
  
  set_table_name :content_top_elements
  belongs_to :element, :polymorphic => true
  
  ELEMENT_TYPES = [
                    ["Blogeinträge", "BlogPost"],
                    ["Aktionen", "Activity"],
                    ["Termine", "Event"],
                  ] unless defined? ELEMENT_TYPES

end