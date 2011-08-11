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
class BlogContentVideoWithCode < ActiveRecord::Base
  include ActionView::Helpers
  ALLOWED_SITES = %w(taz.de bewegung.taz.de player.vimeo.com youtube.com www.youtube.com maps.google.de maps.google.com flickr.com www.flickr.com www.vimeo.com) unless defined?(ALLOWED_SITES)
  
  attr_accessor :contentable_type
  has_one :blog_post_content, :as => :contentable
  validates_presence_of :code
  
  validate :check_code
  
  before_validation :sanitize_code
  before_save :sanitize_code
  protected 
  
  def sanitize_code
    self.code = sanitize(self.code, :tags => %w(object param embed a iframe img), :attributes => %w(frameborder name value href data width height type src allowfullscreen allowscriptaccess))
  end
  
  def check_code
    doc = Nokogiri::HTML(self.code).search("iframe")
    
    if doc.length == 1
      check_iframe(doc.first)
    end
    
    if doc.length > 1
      errors.add(:code, "Bitte maximal ein Iframe einbinden")
    end
    
  end

  def check_iframe(doc)
    host = URI.parse(doc.attributes["src"]).host
    errors.add(:code, "Diese Domain wird nicht unterstützt") unless ALLOWED_SITES.include?(host)
  end
  
end
