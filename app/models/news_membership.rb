class NewsMembership < ActiveRecord::Base
  
  # Associations
  belongs_to :news
  belongs_to :news_category  
  
end
