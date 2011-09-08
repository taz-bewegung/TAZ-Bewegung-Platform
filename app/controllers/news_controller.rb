class NewsController < ApplicationController
  
  layout 'content'
  
  def index
    @news = News.find :all, :order => "created_at DESC", :conditions => ['press_news = ?', false]
  end
  
  def show
    @news = News.find_by_permalink(params[:id])
  end
  
end
