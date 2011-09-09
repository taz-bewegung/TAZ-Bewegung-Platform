# encoding: UTF-8
class Admin::DonationsController < ApplicationController
  
  layout 'admin'
  before_filter :user_login_required
  before_filter :setup
  ssl_required :index  
  access_control :DEFAULT => '(admin | news)'
  
  def index
    @search = Search::Admin::Donation.new(params[:search_admin_donation])
    @search.add_condition("donations.successfull" => true)     
    @donations = @search.search(params[:page])
    @path = admin_donations_path
  end
  
  private
  
    def setup
      params[:search_admin_donation] = {} if params[:search_admin_donation].blank?          
    end
  
end
