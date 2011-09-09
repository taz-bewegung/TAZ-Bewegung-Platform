# encoding: UTF-8
class BlogPost < ActiveRecord::Base  
  
  include Commentable
  
  before_create :set_unique_permalink  
  
  # Plugins
  acts_as_taggable_on :blog_tags
  acts_as_paranoid  
  
  # Associations
  belongs_to :blog
  belongs_to :blogger, :polymorphic => true
  def author; self.blogger; end
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :blog_post_contents, :order => :position, :class_name => "BlogPostContent", :dependent => :destroy
  has_many :feed_events, :as => :trigger, :dependent => :destroy        
  
  validates_presence_of :title
  
  accepts_nested_attributes_for :blog_post_contents, :allow_destroy => true
  
  
  # Scopes
  #named_scope :recent, { :order => "blog_posts.created_at DESC" }
  #named_scope :latest, { :order => "blog_posts.created_at DESC" }    
  #named_scope :published, { :conditions => { :state => "published" } }
  #named_scope :active, { :conditions => { :state => "published" } }  
  #named_scope :with_tags, { :conditions => ["blog_posts.temp_tag_list != '' "] }
  #named_scope :unpublished, { :conditions => { :state => "unpublished" } }  
  #named_scope :not_created, { :conditions => ["blog_posts.state != 'created'"] }
  #named_scope :with_active_organisation, { :include => { :blog => :bloggable } }
  #named_scope :for, lambda { |type| 
  #  { :conditions => ["blogs.bloggable_type = ?", type], :include => :blog }
  #}  
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}
  #
  #named_scope :months_count, {
  #  :select => 'COUNT(uuid) as cnt, MONTH(created_at) as month, YEAR(created_at) as year', 
  #  :group => 'MONTH(created_at), YEAR(created_at)'
  #}
  #named_scope :by_month_and_year, lambda { |month_id, year_id| 
  #  { :conditions => ["MONTH(created_at) = ? AND YEAR(created_at) = ?", month_id, year_id],
  #    :order => "created_at ASC"
  #  }
  #}
  #named_scope :previous, lambda { |post| 
  #  { :conditions => ["blog_posts.created_at < ?", post.created_at],
  #    :order => "blog_posts.created_at DESC",
  #    :limit => 1
  #  }
  #}
  #named_scope :next, lambda { |post| 
  #  { :conditions => ["blog_posts.created_at > ?", post.created_at],
  #    :order => "blog_posts.created_at ASC",
  #    :limit => 1
  #  }
  #}

  class << self

    def recent
      order("blog_posts.created_at DESC")
    end

    def published
      where("state", "published")
    end
    
    def with_active_organisation
      includes({ :blog => :bloggable })
    end
    
    def limit(num)
      limit(num.flatten.first || (defined?(per_page) ? per_page : 10))
    end
    
  end


  # State machine
  acts_as_state_machine :initial => :unpublished
  state :unpublished, :enter => :do_unpublish
  state :published, :enter => :do_publish

  event :publish do
    transitions :from => :unpublished, :to => :published
  end  
  
  event :unpublish do
    transitions :from => :published, :to => :unpublished
  end  
  
  def do_publish
    self.blog.tag(self, :with => self.temp_tag_list, :on => :blog_tags)
    self.notify_observers :blog_post_published
  end
  
  def do_unpublish
    self.blog.tag(self, :with => "", :on => :blog_tags)
    self.feed_events.destroy_all
  end

  
  
  ##
  # Methods   
  
  def to_param
    permalink || id
  end 
  
  def self.find_by_identifier(identifier)
    find(:first, :conditions => ['uuid = ? OR permalink = ?', identifier, identifier])
  end
    
  def set_unique_permalink
    temp_permalink = self.title.to_permalink
    count = self.blog.posts.count :conditions => ["permalink LIKE ? AND uuid != ?", "#{temp_permalink}%", self.id.to_s]
    if count == 0
      self.permalink = temp_permalink
    else
      self.permalink = "#{temp_permalink}-#{(count.to_i + 1).to_s}".to_permalink 
    end
  end
  
  def assign_tags
    self.blog.tag(self, :with => "", :on => :blog_tags)
    self.blog.tag(self, :with => self.temp_tag_list, :on => :blog_tags) if self.published?
  end
    
end
