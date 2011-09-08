class PressController < ApplicationController
  
  layout 'content'
  
  def index
  end
  
  def categories
    @category = NewsCategory.find_by_permalink params[:id]
    @news = @category.news.find :all, :order => "published_on DESC", :conditions => ['press_news = ?', true]
    @news.uniq!    
  end 
  
  def show
    @news = News.find_by_permalink(params[:id])
  end   
  
end
