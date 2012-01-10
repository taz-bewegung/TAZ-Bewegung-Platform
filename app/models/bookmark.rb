# encoding: UTF-8
class Bookmark < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :user
  belongs_to :bookmarkable, :polymorphic => true

end