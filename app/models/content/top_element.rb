# encoding: UTF-8
class Content::TopElement < ActiveRecord::Base
  
  set_table_name :content_top_elements
  belongs_to :element, :polymorphic => true
  
  ELEMENT_TYPES = [
                    ["Blogeinträge", "BlogPost"],
                    ["Aktionen", "Activity"],                    
                    ["Termine", "Event"],                                        
                  ] unless defined? ELEMENT_TYPES

end
