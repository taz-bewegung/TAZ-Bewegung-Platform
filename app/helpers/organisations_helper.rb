module OrganisationsHelper

  def country_flags_for(organization)
    flag_list = ""
    countries = organization.countries.sort{|a,b| a.de <=> b.de}
    countries.each do |country|
      flag_list += image_tag("/images/flags/#{country.code.downcase}.png", :alt => country.de, :title => country.de, :style => "float: none;")
      unless country == countries.last
        flag_list += "&nbsp;"
      end
    end    
    flag_list.blank? ? "-" : flag_list 
  end  
  
  
  def render_organisation_info_box(organisation, mode)
    if organisation == current_user
      case mode
      when :public
        page = "Öffentliches Profil"
        message = " "
        link = link_to "Profil bearbeiten", my_helpedia_organisation_path(organisation)
      when :private
        page = "Organisationsprofil"
        unless organisation.active?
          message = "Organisation ist noch nicht freigeschaltet"          
        else
          link = link_to("Öffentliches Profil anzeigen", organisation_path(organisation))        
        end
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end  

  def organisation_sub_menu_items
    items = []                    
    #items << { :name => t(:"organisation.public_profile.sub_content.tabs.overview.title"), 
    #           :link_to => organisation_path(@organisation, :anchor => "overview"), 
    #           :id => :overview  }
    items << { :name => t(:"organisation.public_profile.sub_content.tabs.about.title"), 
               :link_to => about_organisation_path(@organisation, :anchor => "about"), 
               :id => :about  }
    items << { :name => "Blog", 
              :link_to => organisation_blog_path(@organisation, :anchor => "blog"), 
              :id => :blog } unless @organisation.blog.posts.published.blank?         
    items << { :name => t(:"organisation.public_profile.sub_content.tabs.activities.title"), 
               :link_to => organisation_activities_path(@organisation, :anchor => "activities"), 
               :id => :activities } unless @organisation.activities.running.blank?
    items << { :name => "Termine", 
               :link_to => organisation_events_path(@organisation, :anchor => "events"), 
               :id => :events } unless @organisation.committed_events.blank?
    items << { :name => "Orte", 
               :link_to => organisation_locations_path(@organisation, :anchor => "locations"), 
               :id => :locations } unless @organisation.locations.blank?
    items << { :name => t(:"activity.public_profile.sub_content.tabs.members.title"), 
               :link_to => organisation_activity_memberships_path(@organisation, :anchor => "activity_memberships"), 
               :id => :activity_memberships } unless @organisation.activity_memberships.active.blank?
    items    
  end
  
  def organisation_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => organisation_sub_menu_items, :active => active}
  end  
  
  def organisation_register_sub_menu_items
    items = []                    
    items << { :name => "1: Anmelde-Informationen", 
               :id => :login }
    items << { :name => "2: Ansprechpartner", 
              :id => :profile }               
    items << { :name => "3: Organisationsdaten", 
               :id => :organisation_data }
    items << { :name => "4: Organisationsprofil", 
               :id => :organisation_profile }
    items    
  end

  def organisation_register_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => organisation_register_sub_menu_items, :active => active}
  end
  
  
  def organisation_context_menu(organisation)
    items = []
    items << { :name => t(:"context_menu.public.shared.bookmark.create"), 
               :link_to => organisation_bookmarks_path(organisation),
               :options => { :class => "ajax-link-post" },
               :id => "bookmark_#{organisation.id}" } if organisation.bookmarkable_for?(current_user)
    items << { :name => t(:"context_menu.public.shared.bookmark.destroy"), 
              :link_to => organisation_bookmark_path(organisation, organisation.bookmarks.find_by_user_id(current_user.id)),
              :options => { :class => "ajax-link-delete-without-confirm" },
              :id => "bookmark_#{organisation.id}" } if organisation.bookmarked_by?(current_user)

    items << { :name => "... Nachricht an die Organisation",
               :link_to => polymorphic_path([:new, organisation, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{organisation.id}" } if current_user != organisation

    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
    
  
  
  
end
