module UsersHelper               
  
  def user_status_for(user)
    if user.pending?
      html = t(:"user.states.pending", :date => l(user.created_at))
    elsif user.active?
     # html = t(:"user.states.active", :date => l(user.activated_at))
    elsif user.suspended?
      html = t(:"user.states.suspended", :date => l(user.activated_at))
    end
    html
  end
  
  # Renders the profiles info box
  def render_user_info_box(user, mode)
    if user == current_user
      case mode
      when :public
        page = t(:"user.info_box.public_profile.current_page")
        message = unless user.visible? then t(:"user.info_box.public_profile.profile_not_visible") else "" end 
        link = link_to(t(:"user.info_box.public_profile.edit_link"), my_helpedia_path)
      when :private
        page = "Meine Seite"
        message = ""
        unless user.visible?
          link = t(:"user.info_box.private_profile.edit_link_not_visible")
        else
          link = link_to(t(:"user.info_box.private_profile.edit_link"), user_path(user))          
        end
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end

  
  def user_sub_menu_items
    items = []                    
    #items << { :name => t(:"user.public_profile.sub_content.tabs.overview.title"), 
    #           :link_to => user_path(@user), 
    #           :id => :overview  }
    items << { :name => "Über mich",
               :link_to => user_path(@user), 
               :id => :about }
    items << { :name => "Bezugsgruppe",
               :link_to => user_friendships_path(@user),
               :id => :friendships } unless @user.friendships.accepted_with_user.blank?
    items << { :name => t(:"user.public_profile.sub_content.tabs.activities.title"),
               :link_to => user_activities_path(@user), 
               :id => :activities } unless @user.activities.running.blank?
    items << { :name => "Termine",
               :link_to => user_events_path(@user), 
               :id => :events } unless @user.events.upcoming.blank?
    items << { :name => "Orte", 
               :link_to => user_locations_path(@user), 
               :id => :locations } unless @user.locations.blank?
    items << { :name => t(:"user.public_profile.sub_content.tabs.external_profile_memberships.title"),
               :link_to => user_external_profile_memberships_path(@user), 
               :id => :links } unless @user.external_profile_memberships.blank?
    items << { :name => 'Sympathisierungen',
               :link_to => user_activity_memberships_path(@user),
               :id => :memberships } unless @user.activity_memberships.blank?
    items    
  end
  
  def user_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => user_sub_menu_items, :active => active}
  end
  
  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={})
    raise "Invalid user" unless user
    options.reverse_merge! :content_method => :email, :title_method => :email, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    case user.class.to_s
      when "User" then return link_to(h(content_text), user_path(user), options.reverse_merge!(:rel => "nofollow"))
      when "Organisation" then return link_to(h(content_text), organisation_path(user), options)
    end
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address 
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_user
      [:content_method, :title_method].each{|opt| options.delete(opt)} 
      link_to_login_with_IP content_text, options
    end
  end
  
  def user_profile_link_for(user, options = {})
    content_text      = options.delete(:content_text)
    content_text    ||= user.full_name
    
    case user.class.to_s
      when "User" 
        if logged_in? and user.visible_for_logged_in?
          return link_to(h(content_text), user_path(user), options.reverse_merge!(:rel => "nofollow"))
        elsif not logged_in? and user.visible_for_public?
          return link_to(h(content_text), user_path(user), options.reverse_merge!(:rel => "nofollow"))
        else
          return content_text
        end        
        return 
      when "Organisation" then return link_to(h(content_text), organisation_path(user), options)
    end
    
  end
  
  def logged_in?
    current_user?
  end
  
  def user_context_menu(user)
    items = [] 
    items << { :name => t("context_menu.public.shared.create_message.type_#{user.gender.to_i}"),
               :link_to => polymorphic_path([:new, user, :message], { :format => :lightbox }), 
               :options => { :class => "remote-lightbox" },
               :id => "message_#{user.id}" } if current_user != user

   items << { :name => t("context_menu.public.shared.create_friendship.type_#{user.gender.to_i}"), 
              :link_to => user_friendships_path(user), 
              :options => { :class => "ajax-link-post" },
              :id => "message_#{user.id}" } if current_user != user and user.friendable_for?(current_user)
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end
  
  def text_empty(text)
    if text.empty?
      return "-"
    else
      return text
    end
  end

end
