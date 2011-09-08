module BlogCommentsHelper
  
  # Renders the comment form depending of the commentables settings.
  def comment_form_for_post(commentable, post = nil)
    
    polymorphic_array = [commentable]
    
    # This must be a blog post
    unless post.blank?
      polymorphic_array << post 
      commentable_item = post
    else
      commentable_item = commentable  
    end
    
    return render(:partial => "/comments/comment_form", 
                  :locals => { :polymorphic_array => polymorphic_array }) if commentable_item.commentable.to_s == BlogPost::COMMENTS_ALLOWED or (logged_in? and commentable_item.commentable.to_s == BlogPost::COMMENTS_ALLOWED_FOR_USERS)
    return render(:partial => "/comments/comment_form_no_comments",
                  :locals => { :polymorphic_array => polymorphic_array }) if commentable_item.commentable.to_s == BlogPost::COMMENTS_NOT_ALLOWED
    return render(:partial => "/comments/comment_form_login_required",
                  :locals => { :polymorphic_array => polymorphic_array }) if not logged_in? and commentable_item.commentable.to_s == BlogPost::COMMENTS_ALLOWED_FOR_USERS
  end
  
  # Renders the name for a comment. 
  def name_link_for_comment(comment)
    if comment.author.blank?
      comment.website.blank? ? h(comment.name) : content_tag(:a, h(comment.name), :href => comment.website, :target => "_blank")
    else
      user_profile_link_for(comment.author)
    end
  end
  
  # Renders the image for a comment. If a registered user posted a comment, his/her image is taken. Otherwise we
  # look for a gravatar or then present a default image.
  def image_or_gravatar_for_comment(comment, size = 78)
    if comment.author.blank?
      image_tag comment.gravatar_url(:size => size, :default => "#{application.site_url}/images/default/comment.gif")    
    else
      image_for(comment.author, :"#{size}x#{size}c")
    end    
  end
  
  # Renders the meta infos for a comment.
  def meta_info_for_comment(comment)
    unless comment.author.blank?
      html = content_tag :div do
              concat(content_tag(:div, "Seit: #{l(comment.author.created_at.to_date, :format => :month_year)}"))
              concat(content_tag(:div, "Beiträge: #{comment.author.comments.visible.count}"))
            end
      html
    end
  end
  
end
