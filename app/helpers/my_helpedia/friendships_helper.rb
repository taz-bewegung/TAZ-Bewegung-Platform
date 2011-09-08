module MyHelpedia::FriendshipsHelper
  
  def my_helpedia_user_friendship_menu(active)
    items = []                                         
    items << { :name => 'Mit folgenden AktivistInnen bin ich vernetzt', 
               :link_to => my_helpedia_friendships_path(:state => "accepted"), 
               :id => :friends,          
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" }}
    items << { :name => 'Anfragen an mich', 
               :link_to => my_helpedia_friendships_path(:state => "requested"), 
               :id => :friends_to_accept, 
               :icon_class => :requested,               
               :icon => current_user.friendships.requested.count,
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'meine Anfragen', 
               :link_to => my_helpedia_friendships_path(:state => "pending"), 
               :id => :friends_pending, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => image_tag("spinner.gif"), 
               :id => :spinner,
               :style => "display: none; padding-top: 7px;" }
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end
  
    
  def my_helpedia_friendship_context_menu(friendship)
    items = []                    
    items << { :name => "... Vernetzung bestätigen", 
               :link_to => accept_my_helpedia_friendship_path(friendship),
               :options => { :class => "ajax-link-put" },
               :id => "accept_friendship_#{friendship.id}" } if friendship.requested? 
    items << { :name => "... Vernetzung ablehnen", 
              :link_to => deny_my_helpedia_friendship_path(friendship),
              :options => { :class => "ajax-link-put" },
              :id => "deny_friendship_#{friendship.id}" } if friendship.requested?
    items << { :name => "... Vernetzung beenden", 
              :link_to => my_helpedia_friendship_path(friendship),
              :options => { :class => "ajax-link-delete" },
              :id => "delete_friendship_#{friendship.id}" } if friendship.accepted? or friendship.pending?
    items << { :name => t("context_menu.public.shared.create_message.type_#{friendship.friend.gender.to_i}"),
               :link_to => polymorphic_path([:new, friendship.friend, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{friendship.friend.id}" }

    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
  
end
