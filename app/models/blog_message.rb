class BlogMessage < ActiveRecord::Base
  
  # Associations
  belongs_to :blog, :polymorphic => true
  belongs_to :blogger, :foreign_key => "blogger_id", :class_name => "User"

  has_one :image, :through => :image_attachment
  has_one :image_attachment, :as => :attachable, :dependent => :destroy  
  has_many :feed_events, :as => :trigger, :dependent => :destroy
  
  
  # Validations
  validates_presence_of :title
  validates_presence_of :message 
  
  attr_accessor :temp_image
  
  def temp_id
    self.id || "0"
  end  
  
  scope :latest, { :order => "blog_messages.created_at DESC" }    
  
  # Static find methods
  
  def self.posts_months_count()
    find(:all, 
          :select => 'COUNT(uuid) as cnt, MONTH(created_at) as month, YEAR(created_at) as year', 
          :group => 'MONTH(created_at), YEAR(created_at)')
  end
  
  def self.month_posts(monthid, yearid)
      find(:all,
           :conditions => "MONTH(created_at) = #{monthid} AND YEAR(created_at) = #{yearid}",
           :order => "created_at asc")
  end 
  
end
