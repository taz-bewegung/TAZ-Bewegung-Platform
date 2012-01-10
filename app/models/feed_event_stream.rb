# encoding: UTF-8
class FeedEventStream < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :streamable, :polymorphic => true
  belongs_to :feed_event

end