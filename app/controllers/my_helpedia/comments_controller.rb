class MyHelpedia::CommentsController < ApplicationController

  ##
  # Filter
  before_filter :login_required
  before_filter :find_bloggable
  before_filter :find_comment, :only => [:hide, :unhide, :destroy]
  ssl_required :index, :hide, :unhide, :destroy, :no_blog


  ##
  # List actions

  def index
    @comments = Comment.paginate(:page => params[:page],
                                 :per_page => 400,
                                 :conditions => { :commentable_id => @bloggable.blog.posts })
    @sub_partial = "/my_helpedia/comments/comments"
    respond_to do |format|
      format.html do
        render :partial => "/my_helpedia/#{current_user.class.name.underscore.pluralize}/show/show",
               :layout => true, :locals => { :content_partial => @sub_partial }
      end
      format.js do
        render :update do |page|
          page["sub-content"].replace_html :partial => @sub_partial
        end
      end
    end
  end

  def no_blog
    @comments = @bloggable.comments.paginate(:page => params[:page],
                                             :per_page => 400)
    respond_to do |format|
      format.html do
        render :partial => "/my_helpedia/#{@bloggable.class.name.underscore.pluralize}/show/show",
               :layout => true, :locals => { :content_partial => "no_blog" }
      end
      format.js do
        render :update do |page|
          page["sub-content"].replace_html :partial => @sub_partial
        end
      end
    end
  end



  ##
  # Single comment actions

  def hide
    @comment.hide!
    render :update do |page|
      page["separator-comment_#{@comment.id}"].remove
      page["comment_#{@comment.id}"].replace :partial => "/my_helpedia/comments/comment", :locals => { :comment => @comment }
    end
  end

  def unhide
    @comment.unhide!
    render :update do |page|
      page["separator-comment_#{@comment.id}"].remove
      page["comment_#{@comment.id}"].replace :partial => "/my_helpedia/comments/comment", :locals => { :comment => @comment }
    end
  end

  def destroy
    @comment.destroy
    render :update do |page|
      page["separator-comment_#{@comment.id}"].remove
      page["comment_#{@comment.id}"].remove
    end
  end


  ##
  # Private methods

  private

    # Find the comment
    def find_comment
      @comment = Comment.find(params[:id])
    end

    # Finds the polymorphic bloggable element
    def find_bloggable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bloggable =  $1.classify.constantize.find_by_permalink(value)
          self.instance_variable_set("@#{$1}", @bloggable)
        end
      end
    end

end
