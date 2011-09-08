# encoding: UTF-8
module MyHelpedia::UsersHelper

  def my_helpedia_user_sub_menu_items
    items = []                    
    items << { :name => 'Was passiert gerade...',
               :link_to => my_helpedia_feed_events_path,
               :id => :feed_events }
    items << { :name => 'Meine Seite', :link_to => edit_my_helpedia_user_path(@user), :id => :profile }
    items << { :name => 'Nachrichten', 
               :link_to => my_helpedia_messages_path, 
               :id => :messages,
               :icon => current_user.all_received_messages.unread.count }    
    items << { :name => 'Termine', 
               :link_to => my_helpedia_events_path, 
               :id => :events } unless @user.events.blank?               
    items << { :name => 'Aktionen', 
               :link_to => my_helpedia_activities_path, 
               :id => :activities } unless @user.activities.blank?
    items << { :name => 'Orte', 
               :link_to => my_helpedia_locations_path, 
               :id => :locations } unless @user.locations.blank?
    items << { :name => 'Bezugsgruppe', 
               :link_to => my_helpedia_friendships_path, 
               :id => :friendships,
               :icon => current_user.friendships.requested.count } unless @user.friendships.blank?
    items << { :name => 'Favoriten',
               :link_to => my_helpedia_bookmarks_path,
               :id => :bookmarks } unless @user.bookmarks.blank?
    items << { :name => 'Sympathisierungen',
               :link_to => my_helpedia_activity_memberships_path,
               :id => :memberships } unless @user.activity_memberships.blank?
    items
  end

  def my_helpedia_user_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => my_helpedia_user_sub_menu_items, :active => active}
  end
  
  def get_country_translation(country)
    unless country.blank?
      html = "<dd>"
    
      if country.length <= 2
        html += t(:"countries.#{country}")
      else
        html += country
      end
      html += "</dd>"
    else
      html = "<dd> kein Land ausgewählt </dd>"
    end
    
    html
  end
  
  
  def my_helpedia_user_feed_event_menu(active)
    items = []                                         
    items << { :name => '...in meinem Netzwerk', 
               :link_to => my_helpedia_feed_events_path, 
               :id => :feeds,          
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" }}
    items << { :name => '...in meiner Nähe', 
               :link_to => around_my_helpedia_feed_events_path, 
               :id => :around, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end  
  
    
  
end
