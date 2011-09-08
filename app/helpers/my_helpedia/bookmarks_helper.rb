module MyHelpedia::BookmarksHelper
  
  def my_helpedia_user_bookmark_menu(active)
    items = []                                         
    items << { :name => 'Termine', 
               :link_to => my_helpedia_bookmarks_path(:type => :events), 
               :id => :events,          
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" }}
    items << { :name => 'Aktionen', 
               :link_to => my_helpedia_bookmarks_path(:type => :activities), 
               :id => :activities, 
               :icon_class => :requested,               
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Orte', 
               :link_to => my_helpedia_bookmarks_path(:type => :locations),
               :id => :locations, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Organisationen', 
               :link_to => my_helpedia_bookmarks_path(:type => :organisations), 
               :id => :organisations, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => image_tag("spinner.gif"), 
               :id => :spinner,
               :style => "display: none; padding-top: 7px;" }
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end  
  
  
end
