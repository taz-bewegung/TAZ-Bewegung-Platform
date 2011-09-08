module MyHelpedia::BlogPostsHelper
  
  def render_blog_content_elements(post)
    for element in post.blog_post_contents
      html = concat render_content(element)
    end
    html
  end
  
  def render_content(content)
    render :partial => "/my_helpedia/blog_post_contents/#{content.contentable_type.underscore}",
           :locals => { :content => content.contentable }    
  end
  
end
