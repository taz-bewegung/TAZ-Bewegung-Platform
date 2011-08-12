class Content::WelcomePageTeaser < ActiveRecord::Base

  set_table_name "content_welcome_page_teasers" 

  has_one :content, :as => :element
  belongs_to :element, :polymorphic => true
  has_one :image, :class_name => "Content::WelcomePageTeaserImage", :foreign_key => "content_welcome_page_teaser_id"

  ELEMENT_TYPES = [
                    ["Aktion", "Activity"],
                    ["Termin", "Event"],
                    ["Ort", "Location"],
                    ["Organisation", "Organisation"]
                  ] unless defined? ELEMENT_TYPES

end