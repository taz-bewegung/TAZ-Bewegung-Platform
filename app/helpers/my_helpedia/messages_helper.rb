module MyHelpedia::MessagesHelper
  
  def my_helpedia_user_message_menu(active)
    items = []                    
    items << { :name => 'Posteingang', 
               :link_to => my_helpedia_messages_path, 
               :id => :index,
               :icon => current_user.received_messages.unread.count,
               :icon_class => :received,
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Gesendete Nachrichten', 
               :link_to => sent_my_helpedia_messages_path, 
               :id => :sent, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'System-Nachrichten', 
               :link_to => system_my_helpedia_messages_path,
               :icon => current_user.system_messages.unread.count,
               :icon_class => :system,
               :id => :system, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Neue Nachricht', 
               :link_to => new_my_helpedia_message_path,
               :id => :new,
               :class => "right",
               :options => { :class => "custom-button-33-beige remote-link", :rel => "spinner" } } if current_user.is_a?(User)
    items << { :name => image_tag("spinner.gif"), 
               :id => :spinner,
               :style => "display: none; padding-top: 7px;" }
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end
  
  def class_for_message(message)
    'unread' if message.read_at.blank? and current_user == message.recipient
  end
  
end
