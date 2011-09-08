class BlogPostsController < ApplicationController

  before_filter :find_association
  before_filter :create_brain_buster, :only => [:show]  

  def index 
    @cache_key = cache_key
    @blog_posts = BlogPost.published.recent.limit(20)
    respond_to do |format|
      format.xml
    end
  end

  def show  
    @post = @bloggable.blog.posts.published.find_by_permalink(params[:id])
    @commentable_item = @post
    type = @bloggable.class.to_s.pluralize.downcase
    @comment = Comment.new    
    render :partial => "/#{type}/show/show", :layout => true, 
                                             :locals => { :content_partial => "show", :sub_menu_active => :blog }
  end

  private

    # Finds the associations
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bloggable =  $1.classify.constantize.find_by_permalink(value, :include => [:blog])
        end
      end

      @activity = @bloggable if @bloggable.is_a?(Activity)
      @organisation = @bloggable if @bloggable.is_a?(Organisation)
    end

end