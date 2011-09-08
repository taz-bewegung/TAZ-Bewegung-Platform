module Admin::MessagesHelper
  
  def admin_user_message_menu(active)
    items = []                    
    items << { :name => 'Alle Nachrichten', 
               :link_to => admin_messages_path, 
               :id => :index, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Gesendete Systemnachrichten', 
               :link_to => sent_admin_messages_path, 
               :id => :system, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }               
    items << { :name => 'Neue Systemnachricht', 
               :link_to => new_admin_message_path,
               :id => :new,
               :class => "right",
               :options => { :class => "custom-button-33-beige remote-link", :rel => "spinner" } }
    items << { :name => "Spinner", 
               :id => :spinner,
               :style => "display: none" }
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end  
  
end
