# encoding: UTF-8
class Admin::NewslettersController < ApplicationController
  
  layout 'admin'
  before_filter :setup
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'
  
  def index
  end
  
  def show
    @client = CampaignMonitor::Client.new("f04fd31bd30bb7d7030d74904afedb07")

    # Fetch the subscriber list
    @list = CampaignMonitor::List.new("aeda779d1afdace3dd7144991cd0a377")
    render :action => :index
  end 
  
  def sync_local
    @client = CampaignMonitor::Client.new("f04fd31bd30bb7d7030d74904afedb07")
    @list = CampaignMonitor::List.new("aeda779d1afdace3dd7144991cd0a377") 
    @list.active_subscribers(Date.today - 50.years).each do |subscriber|
      ns = NewsletterSubscriber.find_by_email(subscriber.email_address)
      if ns.blank?
        ns = NewsletterSubscriber.new(:email => subscriber.email_address)
        ns.confirmed_user = true
        ns.save_with_validation(false)
        ns.update_attribute :state, 'confirmed'        
      end
      
      # Try to find users / organisations
      user = User.find_by_email(subscriber.email_address)
      user = Organisation.find_by_helpedia_contact_email(subscriber.email_address) unless user.blank?
      
      unless user.blank?
        user.update_attribute :subscribed_newsletter, true
      end
    end
    redirect_to :back
  end
  
  def sync_external
    NewsletterSubscriber.find(:all).each do |subscriber|
      subscriber.add_to_compaign_monitor      
    end
    redirect_to :back    
  end  
  
  private
  
    def setup
    end
  
end
