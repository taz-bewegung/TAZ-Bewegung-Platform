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
class FlyerOrder
  include ActiveModel::Validations
  attr_accessor :flyer_amount, :poster_amount, :name, :email, :street, :zip, :city
  #column :flyer_amount, :integer
  #column :poster_amount, :integer  
  #
  #column :name, :string
  #column :email, :string
  #column :street, :string
  #column :zip, :string
  #column :city, :string  
  
  validates_numericality_of :flyer_amount, :allow_blank => true
  validates_numericality_of :poster_amount, :allow_blank => true  
  validates_presence_of :street
  validates_presence_of :city
  validates_presence_of :name
  validates_presence_of :zip  
  validates_presence_of :email
  validates_length_of   :email,    :within => 6..100 #r@a.wk
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  def to_param
    "1"
  end  
  
end
