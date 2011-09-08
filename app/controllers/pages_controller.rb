class PagesController < ApplicationController
  
  layout 'application'
  rescue_from NoMethodError, :with => :render_404   
  
  def index
    @pages = Page.find(:all)
  end

  def show    
    @page = Page.find_by_permalink(params[:url].join("/"))
    raise ActiveRecord::RecordNotFound if @page.nil?
    raise ActiveRecord::RecordNotFound if ActionController:NoMethodError   
  end

  

  def new
    @page = Page.new
  end

  def edit
    @page = Page.find(params[:id])
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = 'Page was successfully created.'
      redirect_to(pages_path)
    else
      render :action => new
    end
  end

  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    redirect_to(pages_url)
  end
 
  
end
