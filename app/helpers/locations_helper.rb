# encoding: UTF-8
module LocationsHelper
  
  def render_location_info_box(location, mode)
    if location.owner == current_user
      message = ''      
      case mode
      when :private
        page = "Ort bearbeiten"
        message = "Der Ort ist momentan gesperrt und nicht für andere sichtbar!" unless location.active?
        link = link_to("Ort anzeigen", location_url(location))
      when :public
        page = "Live-Ansicht"
        message = "Der Ort ist momentan gesperrt und nicht für andere sichtbar!" unless location.active?
        link = link_to("Ort bearbeiten", my_helpedia_location_url(location))        
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end  
  
  def address_or_location_for(object)
    if object.location.blank?
      object.address.to_html_long
    else
      link_to object.location.address.to_html_long, object.location
    end
  end  
  
  def location_sub_menu(active)
    items = []
   # items << { :name => "Übersicht", 
   #            :link_to => location_path(@location, :anchor => "overview"), 
   #            :id => :overview  }    
    items << { :name => "Ortsprofil", 
               :link_to => description_location_path(@location, :anchor => "description"), 
               :id => :description }
    items << { :name => t(:"activity.public_profile.sub_content.tabs.members.title"), 
               :link_to => location_activity_memberships_path(@location, :anchor => "activity_memberships"), 
               :id => :activity_memberships } unless @location.activity_memberships.active.blank?
    items << { :name => "Termine", 
               :link_to => location_events_path(@location, :anchor => "events"), 
               :id => :events } unless @location.events.running.blank?
    render :partial => "/menu/sub_menu", :locals => { :menu_items => items, :active => active}
  end  
  
  
  def location_context_menu(location)
    items = []
    items << { :name => t(:"context_menu.public.shared.bookmark.create"), 
               :link_to => location_bookmarks_path(location),
               :options => { :class => "ajax-link-post" },
               :id => "bookmark_#{location.id}" } if location.bookmarkable_for?(current_user)
    items << { :name => t(:"context_menu.public.shared.bookmark.destroy"), 
              :link_to => location_bookmark_path(location, location.bookmarks.find_by_user_id(current_user.id)),
              :options => { :class => "ajax-link-delete-without-confirm" },
              :id => "bookmark_#{location.id}" } if location.bookmarked_by?(current_user)

    items << { :name => t(:"context_menu.public.location.recommend"),
              :link_to => new_location_commendation_path(location), 
              :options => { :class => "remote-lightbox" },
              :id => "commendation_#{location.id}" }
              
    items << { :name => t("context_menu.public.shared.create_message.type_#{location.owner.gender.to_i}"),
               :link_to => polymorphic_path([:new, location.owner, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{location.id}" } if current_user != location.owner 

   items << { :name => t("context_menu.public.shared.create_friendship.type_#{location.owner.gender.to_i}"), 
              :link_to => user_friendships_path(location.owner), 
              :options => { :class => "ajax-link-post" },
              :id => "message_#{location.id}" } if current_user != location.owner and location.owner.friendable_for?(current_user)
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end  
  
  
end
