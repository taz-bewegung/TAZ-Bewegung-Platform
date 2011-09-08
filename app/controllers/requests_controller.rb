class RequestsController < ApplicationController
  
  ssl_required :new, :create, :index
  ssl_allowed :show  
  
  def index
    @request = Request.new
    render :action => 'new'
  end
  
  def contact
  end
  
  def new
    @request = Request.new
  end
  
  def done
  end
  
  def create
   @request = Request.new(params[:request])
    if @request.valid?
      HelpediaMailer.deliver_new_request(@request.name, @request.email, @request.message)  
      redirect_to done_request_path
    else
      render :action => 'new'
    end    
  end
  
end
