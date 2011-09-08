class MyHelpedia::BlogsController < ApplicationController

  before_filter :setup, :find_association, :login_required, :restrict_access
  uses_tiny_mce :options => TAZ_TINY_MCE_OPTIONS, :only => :show
  ssl_required :index, :show 
  
  # There is no real index-action, so we call show to avoid long urls with uuids for the blog
  def index
    show
  end

  def show
    @posts = @bloggable.blog.posts.not_created.recent.paginate(:page => params[:page], :conditions => { :state => params[:state] })
    @sub_partial = "/my_helpedia/blogs/posts"
    type = @bloggable.class.to_s.downcase.pluralize
    respond_to do |format|
      format.html do 
        render :partial => "/my_helpedia/#{type}/show/show", 
               :layout => true, :locals => { :content_partial => "/my_helpedia/blogs/index" }
      end
      format.js do 
        render :update do |page|
          page["sub-content"].replace_html :partial => @sub_partial
        end
      end
    end
  end

  private 
  
  def setup
    params[:state] = "published" if params[:state].blank?
  end

  # Finds the associations
  def find_association
    params.each do |name, value|
      if name =~ /(.+)_id$/
        @bloggable =  $1.classify.constantize.find_by_permalink(value, :include => [:blog])
        self.instance_variable_set("@#{$1}", @bloggable)                  
      end
    end
    @owner = @bloggable.owner
  end

  def restrict_access
    raise Helpedia::ItemNotVisible unless current_user == @owner
  end
end
