class FeedEventStream < ActiveRecord::Base

  belongs_to :streamable, :polymorphic => true
  belongs_to :feed_event

end