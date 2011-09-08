class MyHelpediaController < ApplicationController

  before_filter :login_required
  
  def index
    redirect_to my_helpedia_feed_events_path
  end  
  
end
