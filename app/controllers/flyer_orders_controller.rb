class FlyerOrdersController < ApplicationController
  
  def new
    @flyer_order = FlyerOrder.new
  end
  
  def create
    @flyer_order = FlyerOrder.new(params[:flyer_order]) 
    render :update do |page|
      if @flyer_order.valid?
        page['#flyer-form'].replace_html :partial => "done"        
        AdminMailer.deliver_new_flyer_order(@flyer_order)  
      else
        page['#flyer-form'].replace_html :partial => "form"
      end      
    end    
  end
  
  def show
  end
  
end
