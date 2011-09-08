class Admin::NewsController < ApplicationController

  layout 'admin'
  before_filter :setup
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'
  ssl_required  :destroy, :index, :show, :cancel_edit_part, :update, :new, :edit, :create
  
  def index
    @news = News.paginate :per_page => 10, :order => 'created_at DESC', :page => params[:page], :include => [:author], :conditions =>  ['press_news = ?', false]
  end

  def show
    @news = News.find(params[:id])
  end

  def new
    @news = News.new
    @form_url = admin_news_path(:part => @news.object_id)
    render :update do |page|
      page.insert_html :after, 'new_news', :partial => "/admin/news/form"
    end    

  end

  def edit
    @news = News.find(params[:id])
    @form_url = admin_news_instance_path(@news, :part => @news.object_id)
    render :update do |page|
      page[params[:part]].replace :partial => "/admin/news/form"
    end    
  end

  def create
    @news = News.new(params[:news])
    @news.author = current_user
    @form_url = admin_news_url(:part => @news.object_id)    
    
    if @news.save
      if params[:image]
        @news.image = Image.find(params[:image])
      end      
      render :update do |page|
        page[params[:part]].replace :partial => "/admin/news/item", :locals => { :news => @news }
      end
    else
      if params[:image]
        @news.temp_image = Image.find(params[:image])
      end      
      render :update do |page|
        page[params[:part]].replace :partial => "/admin/news/form"
      end
    end
  end

  def cancel_edit_part
    if params[:id] != "0"
      @news = News.find(params[:id], :include => [:author]) 
      render :update do |page|
        page[params[:part]].replace :partial => "/admin/news/item", :locals => { :news => @news }
      end    
    else
      render :update do |page|
        page[params[:part]].remove
      end      
    end
  end  

  def update
    @news = News.find(params[:id], :include => [:author])
    @form_url = admin_news_instance_path(@news, :part => @news.object_id)            
    if @news.update_attributes(params[:news])
      @news.image = Image.find(params[:image]) if params[:image]
      render :update do |page|
        page[params[:part]].replace :partial => "/admin/news/item", :locals => { :news => @news }
      end
    else
      @news.temp_image = Image.find(params[:image]) if params[:image] 
      render :update do |page|
        page[params[:part]].replace :partial => "/admin/news/form"
      end      
    end
          
  end


  def destroy
    @news = News.find(params[:id])
    @news.destroy
    render :update do |page|
      page[params[:part]].remove
    end
  end
  
  protected
  
    def permission_denied
      flash[:notice] = "You don't have privileges to access this action"
      redirect_to root_path
    end
  
    
  private

    def setup
    end

end