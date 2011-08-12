class Content::LatestElement < ActiveRecord::Base

  set_table_name :content_latest_elements
  belongs_to :element, :polymorphic => true

end