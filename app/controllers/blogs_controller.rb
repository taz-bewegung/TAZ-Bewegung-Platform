class BlogsController < ApplicationController
  
  before_filter :find_association
  
  # There is no real index-action, so we call show to avoid long urls with uuids for the blog
  def index
    show
  end
    
  def show
    @posts = @bloggable.blog.posts.published.recent.paginate(:page => params[:page]) if params[:tag].blank?
    @posts = @bloggable.blog.posts.published.recent.tagged_with(params[:tag], :on => :blog_tags).paginate(:page => params[:page]) if params[:tag]
    @posts = @bloggable.blog.posts.published.recent.by_month_and_year(params[:month], params[:year]).paginate(:page => params[:page]) if params[:month] and params[:year]

    type = @bloggable.class.to_s.pluralize.downcase      
    
    respond_to do |format|
      format.html do
        render :partial => "/#{type}/show/show", :layout => true, 
                                                 :locals => { :content_partial => "show",
                                                              :sub_menu_active => :blog }
      end
      format.rss { render :partial => "show" }
    end
  end
  
  private
  
    # Finds the associations
    def find_association
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bloggable =  $1.classify.constantize.find_by_permalink(value, :include => [:blog])
          self.instance_variable_set("@#{$1}", @bloggable)          
        end
      end
      raise Helpedia::ItemNotVisible unless @bloggable.visible_for?(current_user)
    end

end
