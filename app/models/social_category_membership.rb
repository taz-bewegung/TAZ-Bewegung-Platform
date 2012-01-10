# encoding: UTF-8
class SocialCategoryMembership < ActiveRecord::Base  

  # Modules
  include Bewegung::Uuid

  belongs_to :member, :polymorphic => true
  belongs_to :social_category

end
