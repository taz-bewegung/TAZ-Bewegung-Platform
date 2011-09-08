# encoding: UTF-8
module FeedEventsHelper
  
  def feed_event_partial_name(event, options = {})
    template_path = "/feed_events/"
    template_path = options[:path] unless options[:path].blank?
    template_path + event.class.name.underscore
  end
  
  def render_changes(feed_event)
    # Delete changes we are not interested in
    feed_event.changes.delete_if { |key, value| [:created_at, :updated_at].include?(key.to_sym) }
    changes = []
    # Format changes
    feed_event.changes.each_pair do |key, value|
      
      field = feed_event.trigger.class.human_attribute_name(key)
      changes << "#{field} geändert von <i>#{v(value[0])}</i> zu <b>#{v(value[1])}</b>"     
    end
    
    return changes.join("<br />")
  end 
  
  
  
end
