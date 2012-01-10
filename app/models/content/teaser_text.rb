# encoding: UTF-8
class Content::TeaserText < Content::Text

  EDIT_TEMPLATE = "/content/landing_page/edit_teaser_text" unless defined? EDIT_TEMPLATE
  PUBLIC_TEMPLATE = "/content/landing_page/teaser_text" unless defined? PUBLIC_TEMPLATE
  
end