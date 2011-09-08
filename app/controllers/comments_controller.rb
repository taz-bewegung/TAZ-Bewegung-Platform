class CommentsController < ApplicationController
  
  before_filter :find_association
  before_filter :validate_brain_buster, :only => [:create]  
  
  # Create a new blog comment.
  # * ajax requests only
  def create

    polymorphic_array = [@bloggable]

    if params[:blog_post_id].present?
      @commentable_item = @bloggable.blog.posts.find_by_permalink params[:blog_post_id]      
      polymorphic_array << @commentable_item
    else
      @commentable_item = @bloggable
    end    
    
    @comment = @commentable_item.comments.build params[:comment]
    @comment.set_author_values_for(current_user) unless current_user.blank?
    @comment.ip = request.remote_ip
    @comment.valid?
    if not @captcha_error and @comment.save
      render :update do |page|       
        if @commentable_item.comments.count > 1
          page.insert_html :bottom, 'comments', :partial => "/comments/comment", :locals => { 
                                                                                            :comment => @comment,
                                                                                            :comment_counter => @commentable_item.comments.visible.count-1 }
        else
          page.insert_html :before, 'comment_form', :partial => "/comments/comments"
        end
        
        @comment = Comment.new          
        page["comment_form"].replace :partial => "/comments/comment_form", :locals => { :polymorphic_array => polymorphic_array }
        page["comment_count"].replace_html I18n.t(:"comments", :count => @commentable_item.comments.visible.count)

      end
    else
      render :update do |page|
        page["comment_form"].replace :partial => "/comments/comment_form", :locals => { :polymorphic_array => polymorphic_array }
      end
    end
  end
  
  private
  
    def render_or_redirect_for_captcha_failure
      @captcha_error = true
    end
  
    # Finds the associations
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bloggable =  $1.classify.constantize.find_by_permalink(value) if $1 != "blog_post"          
        end
      end
    end
  
  
end
