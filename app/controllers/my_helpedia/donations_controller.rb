class MyHelpedia::DonationsController < ApplicationController
  
  before_filter :setup
  before_filter :find_associations, :only => [:index, :export]
  
  # Use SSL for those actions
  ssl_required :index  
  
  def index
    index_for_activity      unless params[:activity_id].blank?
    index_for_organisation  unless params[:organisation_id].blank?
  end 
  
  # Exports donations and sends them to the browser
  def export
    report = Donation.export_to_csv(@donations)
    c = Iconv.new('ISO-8859-15//IGNORE//TRANSLIT','UTF-8')  
    iso_report = c.iconv(report)
        
    send_data iso_report,     :type         => "text/csv",
                              :filename     => "helpedia-spenden-#{Time.now.strftime("%Y-%m-%d-%H-%M")}.csv",
                              :disposition  =>  "attachment"    
  end
  
  private
  
    def index_for_organisation
      render_index_for("organisations", "Spenden für unsere Organisation")      
    end
  
    def index_for_activity
      @user = current_user
      @activity = current_user.activities.find_by_permalink(params[:activity_id])
      @donations = @activity.donations.successfull
      render_index_for("activities", "Spenden für meine Aktion")      
    end  
  
    def render_index_for(type, list_title)
      respond_to do |format|
         format.html do
           render :partial => "my_helpedia/#{type}/show/show", :layout => true, 
                                                               :locals => { :content_partial => "/my_helpedia/donations/index/#{type}/show" }
         end    
         format.js do
           render :update do |page|
             page["sub-content"].replace_html :partial => "/my_helpedia/donations/index/#{type}/list_#{params[:list_type]}", 
                                              :locals => { :donations => @donations,
                                                           :list_title => list_title }             
           end
         end
      end      
    end
    
    def find_associations
      if params[:organisation_id].blank? then return false end
        
      @organisation = current_user 
      @forms_donation_date_select = Forms::DonationDateSelect.new(params[:forms_donation_date_select])             
      unless params[:forms_donation_date_select].blank?  
        @donations = @organisation.donations.successfull.find(:all, :include => [:activity], :conditions => ['elargio_id IS NULL AND created_at > ? AND created_at > ? AND created_at < ?', Time.now-2.months, @forms_donation_date_select.starts_on, @forms_donation_date_select.ends_on] )
      else
        @donations = @organisation.donations.successfull.find(:all, :include => [:activity], :conditions => ['viewed_at IS NULL AND elargio_id IS NULL'])
      end      
    end
    
    def setup
      @template.main_menu :my_helpedia
    end
  
end
