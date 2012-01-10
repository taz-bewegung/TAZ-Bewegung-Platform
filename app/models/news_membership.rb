# encoding: UTF-8
class NewsMembership < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  # Associations
  belongs_to :news
  belongs_to :news_category  
  
end
