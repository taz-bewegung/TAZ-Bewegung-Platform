# encoding: UTF-8
class FeedEventsController < ApplicationController
  
  before_filter :setup
  
  def index
    @feed_events = FeedEvent.public_visible.latest.paginate(:page => params[:page], :per_page => 20)
    @grouped_events = @feed_events.group_by { |e| I18n.l(e.created_at.to_date, :format => "%d. %B %Y") }
    if params[:without_layout]
     # @continued = FeedEvent.public_visible.latest.for_account(current_account).find(:first, 
    #                                                                                  :conditions => ["feed_events.created_at BETWEEN ? AND ? AND feed_events.uuid != ?", 
    #                                                                                   @feed_events.first.created_at.beginning_of_day, 
    #                                                                                   @feed_events.first.created_at,
    #                                                                                   @feed_events.first.uuid]).present?      
      render :partial => "/feed_events/list"
    end
  end
  
  private
  
  def setup
    #@template.main_menu :feed_events
  end
    
end
