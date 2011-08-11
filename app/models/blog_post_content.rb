class BlogPostContent < ActiveRecord::Base
  
  ##
  # Plugins
  acts_as_list :scope => :blog_post_id
  acts_as_paranoid


  ##
  # Associstions
  
  belongs_to :contentable, :polymorphic => true
  belongs_to :blog_post
  
  accepts_nested_attributes_for :contentable, :allow_destroy => true
  
  def build_contentable(params)
    self.contentable = params["contentable_type"].to_class.new
    params.delete "contentable_type" 
    self.contentable.attributes = params
  end
  
  ##
  # Scopes
  
  named_scope :text_element, 
              :joins => 'INNER JOIN blog_content_texts ON blog_post_contents.contentable_id = blog_content_texts.uuid',
              :conditions => ["contentable_type = ? AND blog_content_texts.bodytext != ''", "BlogContentText"]
  
end
