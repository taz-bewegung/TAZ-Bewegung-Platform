# encoding: UTF-8
class Admin::FeedEventsController < ApplicationController

  layout "admin"
  before_filter :login_required, :setup
  ssl_required :index
  
  def index
    cookies[:feed_events] = params[:feed_events].to_yaml    
    @feed_events = FeedEvent.latest.by_type(params[:feed_events]).paginate(:page => params[:page], :per_page => 60)
  end
  
  private
  
    def setup
      cookies[:feed_events] = { } if cookies[:feed_events].blank?
      params[:feed_events] = (YAML.load(cookies[:feed_events].to_s) || { }) if params[:feed_events].blank?
    end
  
end