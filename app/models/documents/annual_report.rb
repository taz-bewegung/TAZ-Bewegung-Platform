# encoding: UTF-8
class AnnualReport < Document

  belongs_to :documentable, :polymorphic => true
  belongs_to :organisation, :foreign_key => :documentable_id

  validates_presence_of :year
  validates_uniqueness_of :year, :scope => :documentable_id
  
end