# encoding: UTF-8
class Content::LandingPageTab < ActiveRecord::Base
  
  set_table_name "content_landing_page_tabs"
  
  has_one :content, :as => :element
  belongs_to :element, :polymorphic => true
  
  has_many :image_attachments, :as => :attachable
  has_many :images, :through => :image_attachments
  
  ELEMENT_TYPES = [
                    ["Aktion", "Activity"],
                    ["Termin", "Event"],
                    ["Ort", "Location"],
                    ["Organisation", "Organisation"]
                  ] unless defined? ELEMENT_TYPES
                  
  attr_accessor :hide_date
  def hide_date
    @hide_date || I18n.l(hide_at.try(:to_date))
  rescue
    ""
  end
  

  def before_save
    if @hide_date.present?
      date = ValidatesTimeliness::Formats.parse self.hide_date, :date
      self.hide_at = ValidatesTimeliness::Parser.make_time(date)
    else
      self.hide_at = ""
    end
  end 

  
end
