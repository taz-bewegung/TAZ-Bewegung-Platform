# encoding: UTF-8
class SocialCategoryMembership < ActiveRecord::Base  

  belongs_to :member, :polymorphic => true
  belongs_to :social_category

end
