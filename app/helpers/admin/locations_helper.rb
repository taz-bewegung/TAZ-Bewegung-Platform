# encoding: UTF-8
module Admin::LocationsHelper

  def location_icons_for(location)
    html = ""
    html << link_to("Sperren", suspend_confirmation_admin_location_path(location), :class => "remote-link") if location.active?
    html << link_to("Aktiv schalten", activate_confirmation_admin_location_path(location), :class => "remote-link") if location.suspended?
    html << link_to("Nachricht an Aktiven", polymorphic_path([:new, location.owner, :message], :format => :lightbox), :class => "remote-lightbox")
    html << link_to("Editieren", edit_admin_location_path(location), :title => "Editieren")    
    html << link_to("Löschen", destroy_confirmation_admin_location_path(location), :class => "remote-link")
    html << link_to("Details", "#detail-#{location.object_id}", :class => "admin-more-link", :title => "Details") 
    html    
  end  
  
  
end
