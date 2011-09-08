# encoding: UTF-8
module Admin::EventsHelper

  # Lists the icons for an event.
  def event_icons_for(event)
    html = ""
    html << link_to("Sperren", suspend_confirmation_admin_event_path(event), :class => "remote-link") if event.active?
    html << link_to("Aktiv schalten", activate_confirmation_admin_event_path(event), :class => "remote-link") if event.suspended?
    html << link_to("Nachricht an Aktiven", polymorphic_path([:new, event.owner, :message], :format => :lightbox), :class => "remote-lightbox")
    html << link_to("Editieren", edit_admin_event_path(event), :title => "Editieren")    
    html << link_to("Löschen", destroy_confirmation_admin_event_path(event), :class => "remote-link")
    html << link_to("Details", "#detail-#{event.object_id}", :class => "admin-more-link", :title => "Details") 
    html    
  end  
  
  
end
