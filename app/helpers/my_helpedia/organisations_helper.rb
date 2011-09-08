module MyHelpedia::OrganisationsHelper
  
  def my_helpedia_organisation_sub_menu_items
    items = []                    
    items << { :name => 'Was passiert gerade...',
               :link_to => my_helpedia_feed_events_path,
               :id => :feed_events }
    items << { :name => "Organisationsprofil", 
               :link_to => edit_my_helpedia_organisation_path(@organisation), 
               :id => :profile  }        
    items << { :name => "Nachrichten", 
               :link_to => my_helpedia_messages_path, 
               :icon => current_user.all_received_messages.unread.count,
               :id => :messages  }               
    items << { :name => "Blog", 
               :link_to => my_helpedia_organisation_blog_path(@organisation), 
               :id => :blog } if @organisation.active?
    items << { :name => t(:"organisation.public_profile.sub_content.tabs.activities.title"), 
              :link_to => my_helpedia_activities_path, 
              :id => :activities } unless @organisation.activities.blank?
    items << { :name => "Termine", 
               :link_to => my_helpedia_events_path, 
               :id => :events } unless @organisation.committed_events.blank?
    items << { :name => "Orte", 
               :link_to => my_helpedia_locations_path, 
               :id => :locations } unless @organisation.locations.blank?
    items << { :name => 'Sympathisanten',
              :link_to => my_helpedia_organisation_activity_memberships_path(@organisation),
              :id => :activity_memberships }  unless @organisation.activity_memberships.blank?               
    items    
  end
  
  def my_helpedia_organisation_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => my_helpedia_organisation_sub_menu_items, :active => active}
  end  

end
