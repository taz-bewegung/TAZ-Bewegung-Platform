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
class Feedback
  include ActiveModel::Validations
  attr_accessor :name, :email, :message, :type, :url
  
  #column :name, :string
  #column :email, :string
  #column :message, :text
  #column :type, :string
  #column :url, :string


  validates_presence_of :message
  
#  apply_simple_captcha :message => "", :add_to_base => true                        
  
  def to_param
    "1"
  end  
  
end