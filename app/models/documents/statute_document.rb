# encoding: UTF-8
class StatuteDocument < Document

  # Modules
  include Bewegung::Uuid

  belongs_to :documentable, :polymorphic => true
  belongs_to :organisation, :foreign_key => :documentable_id
  
end