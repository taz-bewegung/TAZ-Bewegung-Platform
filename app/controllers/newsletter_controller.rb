# encoding: UTF-8
class NewsletterController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 
  def subscribe
    if request.get?
      @newsletter_subscriber = NewsletterSubscriber.new(params[:newsletter_subscriber])
    else
      @newsletter_subscriber = NewsletterSubscriber.new(params[:newsletter_subscriber])
      if @newsletter_subscriber.save
        redirect_to subscribed_newsletter_path
      else
        render :action => 'subscribe'
      end
    end    
  end  
  
  def confirm
    @newsletter_subscriber = NewsletterSubscriber.find_by_confirmation_code(params[:id])
    unless @newsletter_subscriber.blank?
      @newsletter_subscriber.confirm!
      redirect_to confirmed_newsletter_path
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def subscribed
  end       
  
  def confirmed
  end
  
  def unsubscribed
  end

  def unsubscribe
   if request.get?
     @newsletter_subscriber = NewsletterSubscriber.new
   else
     @newsletter_subscriber = NewsletterSubscriber.find_by_email(params[:newsletter_subscriber][:email])
     if !@newsletter_subscriber.nil? && @newsletter_subscriber.destroy
       flash[:notice] = "You have been unsubscribed from Helpedia newsletter"
       redirect_to unsubscribed_newsletter_path
     else
       @newsletter_subscriber = NewsletterSubscriber.new
       @newsletter_subscriber.errors.add(:email, " ist nicht für den Newsletter registriert.")
       render :action => 'unsubscribe'
     end
   end
 end

end