class DocumentsController < ApplicationController

  before_filter :find_documents, :only => :index
  before_filter :login_required  
  
  ssl_required :index, :new, :create, :update
  
  def index
    respond_to do |format|
      format.html { render :partial => 'index', :layout => true }
      format.lightbox { render :partial => 'index', :layout => false }                        
      format.js do
        render :update do |page|
          page['document-content'].replace_html :partial => 'index'
        end
      end
    end
  end
  
  def new
    @document = Document.new
    respond_to do |format|
      format.html { render :partial => '/documents/new', :layout => true }
      format.lightbox { render :partial => '/documents/new', :layout => false }                  
      format.js do
        render :update do |page|
          page['document-content'].replace_html :partial => '/documents/new'
        end
      end
    end    
  end

  def create 
    sleep 1
    @document = Document.new(params[:document])
    @document.owner = current_user
    if @document.save
      DocumentUploadEvent.create :trigger => @document, :operator => current_user
      responds_to_parent do
        render :update do |page|
          page.replace_html 'document-sub-content', :partial => 'list_item', :locals => { :document => @document }
          page.visual_effect :highlight, 'content'
        end
      end
    else
      responds_to_parent do
        render :update do |page|
          page['document-content'].replace_html :partial => '/documents/new'      
        end
      end      
    end
  end

  def update
    @document = Document.find params[:id]
    
    render :update do |page|
      page << "$.nyroModalRemove();"
      page.replace_html params[:part], :partial => 'item'
      page.visual_effect :highlight, params[:part]
    end    
  end


  def destroy
  end
  
  private   
    
    def find_documents
      @documents = current_user.documents
    end
  
end
