module Admin::ActivitiesHelper

  def formal_activity_status_for(activity)
    case activity.state
    when "running" then content_tag(:span, t(:"activity.calculations.time_left", :distance => distance_of_time_in_words_to_now(activity.ends_at)), :class => "green")      
    when "suspended" then content_tag(:span, "gesperrt", :class => "red")
    end
  end  

  # Lists the icons for an activity.
  def activity_icons_for(activity)
    html = ""
    
    html << link_to("Sperren", suspend_confirmation_admin_activity_path(activity), :class => "remote-link") if activity.active?
    html << link_to("Aktiv schalten", activate_confirmation_admin_activity_path(activity), :class => "remote-link") if activity.suspended?
    html << link_to("Nachricht an Aktiven", polymorphic_path([:new, activity.owner, :message], :format => :lightbox), :class => "remote-lightbox") unless activity.owner.nil?
    html << link_to("Editieren", edit_admin_activity_path(activity), :title => "Editieren")    
    html << link_to("Löschen", destroy_confirmation_admin_activity_path(activity), :class => "remote-link")
    html << link_to("Details", "#detail-#{activity.object_id}", :class => "admin-more-link", :title => "Details")    
    
    html    
  end  

end
