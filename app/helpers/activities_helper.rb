# encoding: UTF-8
module ActivitiesHelper
  
  def render_activity_info_box(activity, mode)
    if activity.owner == current_user
      message = ""      
      case mode
      when :private
        page = "Aktion bearbeiten"
        message = "Die Aktion ist momentan gesperrt und nicht für andere sichtbar!" unless activity.active?
        link = link_to("Aktion anzeigen", activity_url(activity))
      when :public
        page = "Live-Ansicht"
        message = "Die Aktion ist momentan gesperrt und nicht für andere sichtbar!" unless activity.active?
        link = link_to("Aktion bearbeiten", my_helpedia_activity_path(activity))        
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end
  
  def activity_sub_menu(active)
    items = []                    
#    items << { :name => t(:"activity.public_profile.sub_content.tabs.overview.title"), 
#               :link_to => activity_path(@activity, :anchor => "title"), 
#               :id => :overview,
#               :options => {:name => "title"}  }
    items << { :name => t(:"activity.public_profile.sub_content.tabs.about.title"), 
               :link_to => description_activity_path(@activity, :anchor => "description"),
               :id => :description, 
               :options => {:name => "description"} }
    items << { :name => "Unterzeichner (#{number_with_delimiter(@activity.petition_users_count, :delimiter => ".")})", 
              :link_to => activity_petition_users_path(@activity, :anchor => "petition_users"), 
              :id => :petition_users,
              :options => {:name => "events"} } if @activity.wikileaked?
    items << { :name => "Unterzeichner (#{number_with_delimiter(@activity.petition_users_count, :delimiter => ".")})", 
              :link_to => activity_petition_users_path(@activity, :anchor => "petition_users"), 
              :id => :petition_users,
              :options => {:name => "events"} } if @activity.iranized?
    items << { :name => t(:"activity.public_profile.sub_content.tabs.blog.title"), 
               :link_to => activity_blog_path(@activity, :anchor => "blog"), 
               :id => :blog,
               :options => {:name => "blog"} } unless @activity.blog.posts.published.blank?                    
    items << { :name => t(:"activity.public_profile.sub_content.tabs.members.title"), 
               :link_to => activity_activity_memberships_path(@activity, :anchor => "activity_memberships"), 
               :id => :activity_memberships,
               :options => {:name => "activity_memberships"} } unless @activity.activity_memberships.active.blank?
    items << { :name => "Zugehörige Termine", 
               :link_to => activity_events_path(@activity, :anchor => "events"), 
               :id => :events,
               :options => {:name => "events"} } unless @activity.events.blank?               
    

     # items << { :name => "Karte einbinden",
     #            :link_to => map_activity_events_path(@activity, :anchor => "events_map"), 
     #            :id => :events_map,
     #            :options => {:name => "events"} } unless @activity.events.blank?
    render :partial => "/menu/sub_menu", :locals => { :menu_items => items, :active => active}
  end
  
  def activity_context_menu(activity)
    items = []
    items << { :name => t(:"context_menu.public.shared.bookmark.create"), 
               :link_to => activity_bookmarks_path(activity),
               :options => { :class => "ajax-link-post" },
               :id => "bookmark_#{activity.id}" } if activity.bookmarkable_for?(current_user)
    items << { :name => t(:"context_menu.public.shared.bookmark.destroy"), 
              :link_to => activity_bookmark_path(activity, activity.bookmarks.find_by_user_id(current_user.id)),
              :options => { :class => "ajax-link-delete-without-confirm" },
              :id => "bookmark_#{activity.id}" } if activity.bookmarked_by?(current_user)
    items << { :name => t(:"context_menu.public.activity.recommend"),
              :link_to => new_activity_commendation_path(activity), 
              :options => { :class => "remote-lightbox" },
              :id => "commendation_#{activity.id}" }
              
    items << { :name => t("context_menu.public.shared.create_message.type_#{activity.owner.gender.to_i}"),
               :link_to => polymorphic_path([:new, activity.owner, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{activity.id}" } if current_user != activity.owner

   items << { :name => t("context_menu.public.shared.create_friendship.type_#{activity.owner.gender.to_i}"), 
              :link_to => user_friendships_path(activity.owner), 
              :options => { :class => "ajax-link-post" },
              :id => "message_#{activity.id}" } if current_user != activity.owner and activity.owner.friendable_for?(current_user)
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end

end
