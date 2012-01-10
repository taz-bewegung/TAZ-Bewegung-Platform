class MyHelpedia::BlogPostContentsController < ApplicationController

  before_filter :find_association
  before_filter :setup
  before_filter :login_required
  ssl_required :chose, :new, :destroy
  
  def chose
    @blog_post_content = BlogPostContent.new
    render :update do |page|
      page.replace params[:part], :partial => "/my_helpedia/blog_post_contents/chose"
    end
  end
  
  def new 
    blog_post_content = @blog_post.blog_post_contents.new
    blog_post_content_element = params[:type].classify.constantize.new           # Fetch type dynamically
    blog_post_content.contentable = blog_post_content_element

    blog_post_content.position = params[:position]
    @blog_post.blog_post_contents << blog_post_content
    @blog_post.blog.save(false)
    
    render :update do |page|
      page.insert_html :after, params[:part], :partial => "/my_helpedia/blog_post_contents/new", :locals => { :blog_post_content => blog_post_content, :blog_post_content_element => blog_post_content_element }
      page.replace params[:part], :partial => "/my_helpedia/blog_post_contents/#{params[:type]}", :locals => { :blog_post_content => blog_post_content, :blog_post_content_element => blog_post_content_element }
      page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"
    end
  end
  
  def destroy
    content = @blog_post.blog_post_contents.find(params[:id])
    content.destroy
    render :update do |page|
      page[content].remove
    end
  end
  
  
  private
  
    def find_association
      @user = current_user
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bloggable = $1.classify.constantize.find_by_permalink(value) if $1 == "organisation"
          @bloggable = current_user.instance_eval("#{$1.pluralize}.find_by_permalink(value)") if $1 == "activity"
        end
      end      
      @blog_post = @bloggable.blog.posts.find(params[:blog_post_id])
    end
    
    def setup
      view_context.main_menu :my_helpedia
    end  
  
end
