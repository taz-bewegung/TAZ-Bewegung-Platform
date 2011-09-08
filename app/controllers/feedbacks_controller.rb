class FeedbacksController < ApplicationController

  skip_after_filter :store_location
  
  def new
    @feedback = Feedback.new(params[:feedback])
    @feedback.email = current_user.email unless current_user.blank?
    @feedback.name = current_user.name unless current_user.blank?
    render :partial => "new"
  end
  
  def create
    @feedback = Feedback.new(params[:feedback])
    if @feedback.valid?
      AdminMailer.deliver_new_feedback(@feedback, session[:return_to])
      render :update do |page|
        page['#nyroModalContent'].replace_html :partial => "submitted"
      end
    else
      render :update do |page|
        page['#nyroModalContent'].replace_html :partial => "new"
      end
    end    
  end
  
  def submitted
  end 
  
  def show
    raise ActionController::UnknownAction
  end
end
