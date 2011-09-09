require 'httparty'
require 'acts_as_video_fu'
require 'acts_as_video_fu_helper'

ActiveRecord::Base.send(:include, Mdarby::Acts::Acts_as_video_fu)
ActionView::Base.send(:include, Mdarby::Acts::Acts_as_video_fu_helper)

Rails.logger.info "** [acts_as_video_fu] loaded"