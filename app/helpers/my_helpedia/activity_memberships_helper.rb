module MyHelpedia::ActivityMembershipsHelper

  def my_helpedia_user_activity_membership_menu(active)
    items = []
#    items << { :name => 'Termine', 
#               :link_to => my_helpedia_activity_memberships_path(:type => :events), 
#               :id => :events,          
#               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" }}
    items << { :name => 'Aktionen', 
               :link_to => my_helpedia_activity_memberships_path(:type => :activities), 
               :id => :activities, 
               :icon_class => :requested,               
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Orte', 
               :link_to => my_helpedia_activity_memberships_path(:type => :locations),
               :id => :locations, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Organisationen', 
               :link_to => my_helpedia_activity_memberships_path(:type => :organisations), 
               :id => :organisations, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => image_tag("spinner.gif"), 
               :id => :spinner,
               :style => "display: none; padding-top: 7px;" }    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active }
  end
  
  def user_activity_membership_menu(active)
    items = []
    items << { :name => 'Aktionen', 
              :link_to => user_activity_memberships_path(@user, :type => :activities), 
              :id => :activities, 
              :icon_class => :requested,               
              :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Orte', 
              :link_to => user_activity_memberships_path(@user, :type => :locations),
              :id => :locations, 
              :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Organisationen', 
              :link_to => user_activity_memberships_path(@user, :type => :organisations), 
              :id => :organisations, 
              :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => image_tag("spinner.gif"), 
              :id => :spinner,
              :style => "display: none; padding-top: 7px;" }    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active }
  end  
  
  
  def my_helpedia_activity_activity_membership_menu(active)
    items = []                                         
    items << { :name => 'Aktiv', 
               :link_to => my_helpedia_activity_activity_memberships_path(@activity, :type => :active), 
               :id => :active,          
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" }}  
    items << { :name => 'noch nicht freigeschaltet', 
               :link_to => my_helpedia_activity_activity_memberships_path(@activity, :type => :pending), 
               :icon => @activity.activity_memberships.pending.count,               
               :id => :pending, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => image_tag("spinner.gif"), 
               :id => :spinner,
               :style => "display: none; padding-top: 7px;" }
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active }
  end

  def my_helpedia_activity_activity_membership_context_menu(membership)
    items = []                    
    items << { :name => "... Sympathisierung beenden", 
               :link_to => polymorphic_path([:my_helpedia, membership.activity, membership]),
               :id => dom_id(membership, "delete"),
               :options => { :class => "ajax-link-delete" } }
    items << { :name => t(:"context_menu.public.#{membership.activity.class.to_s.downcase}.recommend"),
              :link_to => polymorphic_path([:new, membership.activity, :commendation]), 
              :options => { :class => "remote-lightbox" },
              :id => "commendation_#{membership.activity.id}" } unless membership.activity.is_a?(Organisation)

    items << { :name => t("context_menu.public.shared.create_message.type_#{membership.activity.owner.gender.to_i}"),
              :link_to => polymorphic_path([:new, membership.activity.owner, :message], { :format => :lightbox }), 
              :options => { :class => "remote-lightbox" },
              :id => "message_#{membership.activity.id}" } if current_user != membership.activity.owner

    items << { :name => t("context_menu.public.shared.create_friendship.type_#{membership.activity.owner.gender.to_i}"), 
             :link_to => user_friendships_path(membership.activity.owner), 
             :options => { :class => "ajax-link-post" },
             :id => "message_#{activity.id}" } if current_user != membership.activity.owner and membership.activity.owner.friendable_for?(current_user)               

    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
  
  def my_helpedia_user_activity_membership_context_menu(membership)
    items = []
    items << { :name => "... Sympathisierung beenden", 
               :link_to => polymorphic_path([:my_helpedia, membership.activity, membership]),
               :id => dom_id(membership, "delete"),
               :options => { :class => "ajax-link-delete" } }
    items << { :name => t(:"context_menu.public.#{membership.activity.class.to_s.downcase}.recommend"),
               :link_to => polymorphic_path([:new, membership.activity, :commendation]), 
               :options => { :class => "remote-lightbox" },
               :id => "commendation_#{membership.activity.id}" } unless membership.activity.is_a?(Organisation)

    items << { :name => t("context_menu.public.shared.create_message.type_#{membership.activity.owner.gender.to_i}"),
               :link_to => polymorphic_path([:new, membership.activity.owner, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{membership.activity.id}" } if current_user != membership.activity.owner

    items << { :name => t("context_menu.public.shared.create_friendship.type_#{membership.activity.owner.gender.to_i}"), 
              :link_to => user_friendships_path(membership.activity.owner), 
              :options => { :class => "ajax-link-post" },
              :id => "message_#{membership.activity.id}" } if current_user != membership.activity.owner and membership.activity.owner.friendable_for?(current_user)               

    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end  
  
end
