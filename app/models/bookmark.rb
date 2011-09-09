# encoding: UTF-8
class Bookmark < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :bookmarkable, :polymorphic => true
      
end
