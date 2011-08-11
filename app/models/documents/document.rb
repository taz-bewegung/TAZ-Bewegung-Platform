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
class Document < ActiveRecord::Base
  
  belongs_to :owner, :polymorphic => true
  has_many :document_attachments, :as => :attachable, :dependent => :destroy  
  has_many :feed_events, :as => :trigger, :dependent => :destroy  
  
  attr_accessor :documentable_id
  
  has_attachment  :content_type => ['application/pdf', 'application/msword', 'application/vnd.oasis.opendocument.text', 'text/plain', 'application/rtf', :image],
                  :storage => :file_system,
                  :path_prefix => 'public/uploads/', 
                  :max_size => 5.megabyte

  def validate
     errors.add_to_base("Bitte ein Dokument auswählen") unless self.filename

     unless self.filename == nil
       [:content_type].each do |attr_name|
         enum = attachment_options[attr_name]
         unless enum.nil? || enum.include?(send(attr_name))
           errors.add_to_base("Das Dokument besitzt ein ungültiges Format!")
         end
       end

       # Images should be less than 3 MB
       [:size].each do |attr_name|
         enum = attachment_options[attr_name]
         unless enum.nil? || enum.include?(send(attr_name))
           errors.add_to_base("Das Dokument muss kleiner als 5 MB sein!")
         end
       end

     end
   end
  
  MEDIA_TYPE = Hash.new unless defined?(MEDIA_TYPE)
  MEDIA_TYPE["image/jpg"] = "jpeg"
  MEDIA_TYPE["image/jpeg"] = "jpeg"
  MEDIA_TYPE["image/pjpeg"] = "jpeg"
  MEDIA_TYPE["text/plain"] = "text"
  MEDIA_TYPE["image/gif"] = "gif"
  MEDIA_TYPE["image/png"] = "png"
  MEDIA_TYPE["image/x-png"] = "png"
  MEDIA_TYPE["application/rtf"] = "rtf"
  MEDIA_TYPE["application/pdf"] = "pdf"
  MEDIA_TYPE["application/msword"] = "word"
  MEDIA_TYPE["application/vnd.ms-excel"] = "excel"
  MEDIA_TYPE["application/vnd.ms-powerpoint"] = "powerpoint"
  MEDIA_TYPE["application/vnd.oasis.opendocument.text"] = "odt"
 
  MEDIA_TYPE_EXTENSION = Hash.new unless defined?(MEDIA_TYPE_EXTENSION)
  MEDIA_TYPE_EXTENSION["image/jpg"] = "jpg"
  MEDIA_TYPE_EXTENSION["image/jpeg"] = "jpg"
  MEDIA_TYPE_EXTENSION["image/pjpeg"] = "jpg"
  MEDIA_TYPE_EXTENSION["text/plain"] = "txt"
  MEDIA_TYPE_EXTENSION["image/gif"] = "gif"
  MEDIA_TYPE_EXTENSION["image/png"] = "png"
  MEDIA_TYPE_EXTENSION["image/x-png"] = "png"
  MEDIA_TYPE_EXTENSION["application/rtf"] = "rtf"
  MEDIA_TYPE_EXTENSION["application/pdf"] = "pdf"
  MEDIA_TYPE_EXTENSION["application/msword"] = "doc"
  MEDIA_TYPE_EXTENSION["application/vnd.ms-excel"] = "xls"
  MEDIA_TYPE_EXTENSION["application/vnd.ms-powerpoint"] = "ppt"
  MEDIA_TYPE_EXTENSION["application/vnd.oasis.opendocument.text"] = "odt"

  def media_type
    MEDIA_TYPE[self.content_type]
  end

  def media_type_extension
    MEDIA_TYPE_EXTENSION[self.content_type]
  end

  def media_type_icon
    "icons/#{MEDIA_TYPE[self.content_type]}.png"
  end  
  
end
