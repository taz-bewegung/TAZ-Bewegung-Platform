class MyHelpedia::BlogPostsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_association
  before_filter :setup
  before_filter :find_post
  
  ssl_required :new, :create, :update, :edit, :destroy, :publish, :unpublish
  
  # Renders the form for creating a blog post.
  def new
    @blog_post = @bloggable.blog.posts.new
    render :update do |page|
      page["sub-content"].replace_html :partial => "new"
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"         
    end    
  end 
  
  # Renders the edit form for a blog post.
  def edit 
    @content = {}
    @blog_post.blog_post_contents.each do |content|
      @content[content.id] = content.contentable
    end
    render :update do |page|
      page["sub-content"].replace_html :partial => "edit"
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
    end    
  end  
  
  def publish
    @blog_post.publish!
  end
  
  def unpublish
    @blog_post.unpublish!
  end
  
  def destroy
    @blog_post.destroy
  end 
  
  def create
    @blog_post = @bloggable.blog.posts.build(params[:blog_post])
    @blog_post.blogger = current_user
    if @blog_post.save
           
      if params[:state] == "published"
        @blog_post.publish! unless @blog_post.published?
      end
      
      @posts = @bloggable.blog.posts.not_created.recent.paginate(:page => params[:page], :conditions => { :state => params[:state] })      
      @sub_partial = "/my_helpedia/blogs/posts"
      
      render :update do |page|
        page["sub-content"].replace_html :partial => "/my_helpedia/blogs/posts"
      end      
      
    else
      render :update do |page|
        page["sub-content"].replace_html :partial => "new" 
        page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
      end
    end
  end
  
  def update
    @blog_post.attributes = params[:blog_post]
    if @blog_post.save
      
      if params[:state] == "published"
        @blog_post.publish! unless @blog_post.published?
      end
      
      @posts = @bloggable.blog.posts.not_created.recent.paginate(:page => params[:page], :conditions => { :state => params[:state] })
      @sub_partial = "/my_helpedia/blogs/posts"
      
      render :update do |page|
        page["sub-content"].replace_html :partial => "/my_helpedia/blogs/posts"
        
      end
    else
      render :update do |page|
        page["sub-content"].replace_html :partial => "new" 
        page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
      end
    end
  end
    
  private 
  
    def find_post
      @blog_post = @bloggable.blog.posts.find_by_identifier(params[:id])
    end
    
    # Finds the associations
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          if $1 == "activity" || $1 == "engagement"
            @bloggable =  current_user.instance_eval("#{$1.pluralize}.find_by_permalink(value)") 
          elsif $1 == "organisation"
            @bloggable =  $1.classify.constantize.find_by_permalink(value)
          end
        end
      end
    end
    
    def setup
      view_context.main_menu :my_helpedia
    end
  
end
