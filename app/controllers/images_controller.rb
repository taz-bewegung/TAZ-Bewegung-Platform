class ImagesController < ApplicationController
  
  before_filter :find_images, :only => :index
  before_filter :login_required  
  
  ssl_allowed :index, :new, :create, :update, :lightbox, :destroy, :crop, :cancel_crop
  
  def lightbox
    @image = Image.new    
    # Render lightbox.js.rjs
  end
  
  def index
    respond_to do |format|
      format.html { render :partial => 'index', :layout => true }
      format.js do
        render :update do |page|
          page['#image-content'].replace_html :partial => 'index'
        end
      end
    end
  end
  
  def new
    @image = Image.new
    respond_to do |format|
      format.html { render :partial => '/images/new', :layout => true }
      format.js do
        render :update do |page|
          page['#image-content'].replace_html :partial => '/images/new'
        end
      end
    end    
  end
  
  # Edit an image (cropping)
  def crop
    @image = Image.find params[:id]
    @image.attributes = params[:image]
    @image.crop!
    render :update do |page| 
      page << "$.nyroModalRemove();"
      page.replace_html params[:part], :partial => 'item' 
      page << "$('##{params[:image_input]}').attr('value', '#{@image.id}')"
    end    
  end
  
  # Just update the page
  def cancel_crop
    @image = Image.find params[:id]
    render :update do |page| 
      page << "$.nyroModalRemove();"
      page.replace_html params[:part], :partial => 'item' 
      page << "$('##{params[:image_input]}').attr('value', '#{@image.id}')"
    end
  end

  def create
    @image = Image.new(params[:image])
    @image.owner = current_user
    if @image.save

      # Track login event
      ImageUploadEvent.create :trigger => @image, :operator => current_user, :concerned => current_user
      
      responds_to_parent do
        render :update do |page| 
          page['#image-content'].replace_html :partial => '/images/edit'          
          #page << "$.nyroModalRemove();"
          #page.replace_html params[:part], :partial => 'item' 
          #page << "$('##{params[:image_input]}').attr('value', '#{@image.id}')" unless params[:multiple].present?
        end
      end
    else
      responds_to_parent do
        render :update do |page|
          page['image-content'].replace_html :partial => '/images/new'
        end
      end      
    end
  end

  def update
    @image = Image.find params[:id]
   
    render :update do |page|
      if params[:multiple].blank?
        page.replace_html params[:part], :partial => 'item'
        page << "$.nyroModalRemove();"          
      else
        page << "$.nyroModalRemove();"
        page.replace_html params[:part], :partial => 'item'        
      end
      page << "$('##{params[:image_input]}').attr('value', '#{@image.id}')"      
    end    
  end

  def destroy
    @image = current_user.images.find params[:id]
    @image.destroy
    render :update do |page|
      page[@image].remove
    end
  end

  
  private   
    
    def find_images
      @images = current_user.images
    end

end
