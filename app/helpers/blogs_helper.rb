module BlogsHelper
  
  def render_teaser_for(post)
    render :partial => "#{post.blog_post_contents.first.contentable_type.underscore}", 
           :locals => { :content => post.blog_post_contents.first.contentable }
  end
  
end
