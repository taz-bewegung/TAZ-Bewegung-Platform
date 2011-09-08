module BlogPostsHelper
  
  def full_blog_post_content_for(post)
    html = ""
    for content in post.blog_post_contents
      html << render(:partial => "/blog_posts/#{content.contentable_type.underscore}.html.erb", :locals => { :content => content.contentable }, :type => :html)
    end
    html
  end
  
end
