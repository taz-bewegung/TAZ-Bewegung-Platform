# encoding: UTF-8
module EventsHelper
    
  # FIXME Using send for urls is not nice, but polymorphic_path doesn't work in this situation (why?)
  def events_for_day(events, day)
    events_on_day = []
    counter = 0;
    events_on_day = events.collect { |e| e.is_on_day?(day) ? point_for_event(e, day, (counter=counter+1)) : nil }.compact
    if events_on_day.size > 0
      items = [content_tag(:span, day.day.to_s, :class => "number") + content_tag(:span, events_on_day.join(" "), :class => "icons") , 
               { :class => "dayWithEvents", 
                 :rel => self.send("for_day_#{events.first.class.to_s.downcase.pluralize}_path", {:day => day}) }]
      items
    else
      content_tag(:span, day.day.to_s, :class => "number") 
    end
  end
  
  def point_for_event(event, day, counter)
    content_tag :span, image_tag("blank.gif", :width => 10, :height => 10), :class => "cal_item_#{counter}"
  end
  
  # Renders the info box on top of the event profile
  def render_event_info_box(event, mode)
    if event.originator == current_user
      message = ''
      case mode
      when :private
        page = "Termin bearbeiten"
        message = "Der Termin ist momentan gesperrt und nicht für andere sichtbar!" unless event.active?
        link = link_to("Termin anzeigen", event_url(event))
      when :public
        page = "Live-Ansicht"
        message = "Der Termin ist momentan gesperrt und nicht für andere sichtbar!" unless event.active?
        link = link_to("Termin bearbeiten", my_helpedia_event_url(event))
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end
  
  def event_status_for(event)
    if event.running?
      html = t(:"event.calculations.time_left", :distance => distance_of_time_in_words_to_now(event.ends_at))      
    elsif event.upcoming?
      html = t(:"event.calculations.time_starting", :distance => distance_of_time_in_words_to_now(event.starts_at))            
    elsif event.finished?
      html = t(:"event.calculations.time_over", :distance => distance_of_time_in_words_to_now(event.ends_at))      
    end
  end
    

  def event_sub_menu(active)
    items = []                    
    items << { :name => "Über den Termin", 
               :link_to => event_path(@event, :anchor => "description"), 
               :id => :description }
    items    
    render :partial => "/menu/sub_menu", :locals => { :menu_items => items, :active => active}    
  end

  
  def event_context_menu(event)
    items = []
    items << { :name => t(:"context_menu.public.shared.bookmark.create"), 
               :link_to => event_bookmarks_path(event),
               :options => { :class => "ajax-link-post" },
               :id => "bookmark_#{event.id}" } if event.bookmarkable_for?(current_user)
    items << { :name => t(:"context_menu.public.shared.bookmark.destroy"), 
              :link_to => event_bookmark_path(event, event.bookmarks.find_by_user_id(current_user.id)),
              :options => { :class => "ajax-link-delete-without-confirm" },
              :id => "bookmark_#{event.id}" } if event.bookmarked_by?(current_user)
    items << { :name => t(:"context_menu.public.event.recommend"), 
              :link_to => new_event_commendation_path(event), 
              :options => { :class => "remote-lightbox" },
              :id => "commendation_#{event.id}" }
              
    items << { :name => t("context_menu.public.shared.create_message.type_#{event.originator.gender.to_i}"),
               :link_to => polymorphic_path([:new, event.originator, :message], { :format => :lightbox}), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{event.id}" } if current_user != event.originator

   items << { :name => t("context_menu.public.shared.create_friendship.type_#{event.originator.gender.to_i}"), 
              :link_to => user_friendships_path(event.originator), 
              :options => { :class => "ajax-link-post" },
              :id => "message_#{event.id}" } if current_user != event.originator and event.originator.friendable_for?(current_user)
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end  
  
end
