module MyHelpedia::LocationsHelper

  def my_helpedia_location_sub_menu(active)
    items = []                    
    #      items << { :name => 'Übersicht', :link_to => my_helpedia_organisation_job_path(@organisation, @job), :id => :overview  }
    items << { :name => 'Orts-Profil', :link_to => edit_my_helpedia_location_path(@location), :id => :profile }
    items << { :name => 'Sympathisanten',
               :link_to => my_helpedia_location_activity_memberships_path(@location),
               :id => :activity_memberships }  unless @location.activity_memberships.blank?    
    items << { :name => 'Kommentare', 
               :link_to => no_blog_my_helpedia_location_comments_path(@location), 
               :id => :comments } if @location.comments.present?
    render :partial => "/menu/sub_menu", :locals => { :menu_items => items, :active => active}    
  end
  
  def my_helpedia_location_context_menu(location)    
    items = []                    
    items << { :name => "... Ort bearbeiten", 
               :link_to => edit_my_helpedia_location_path(location),
               :id => "edit_#{location.id}" }
    items << { :name => "... Ort löschen", 
               :link_to => destroy_confirmation_my_helpedia_location_path(location),
               :options => { :class => "remote-link" },
               :id => "delete_location#{location.id}" }
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
  
  
  
end
