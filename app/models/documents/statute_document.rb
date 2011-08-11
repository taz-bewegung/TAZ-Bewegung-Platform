class StatuteDocument < Document

  belongs_to :documentable, :polymorphic => true
  belongs_to :organisation, :foreign_key => :documentable_id
  
end