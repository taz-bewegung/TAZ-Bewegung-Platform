# encoding: UTF-8
module MyHelpedia::EventsHelper

  def my_helpedia_event_sub_menu_items
    items = []                    
    items << { :name => 'Terminprofil', :link_to => edit_my_helpedia_event_path(@event), :id => :profile }
    items
  end
  
  def my_helpedia_event_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => my_helpedia_event_sub_menu_items, :active => active}
  end 
  
  def my_helpedia_event_context_menu(event)    
    items = []                    
    items << { :name => "... Bearbeiten", 
               :link_to => edit_my_helpedia_event_path(event),
               :id => "edit_#{event.id}" }
    items << { :name => "... Löschen", 
               :link_to => destroy_confirmation_my_helpedia_event_path(event),
               :options => { :class => "remote-link" },
               :id => "delete_#{event.id}" }
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
  
end
