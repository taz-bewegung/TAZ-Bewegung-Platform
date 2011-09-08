module Admin::UsersHelper
  
  # Lists the icons for a user.
  def user_icons_for(user)
    html = ""

    if user.active?    
      html << link_to(image_tag("fam-icons/delete.png"), suspend_confirmation_admin_user_path(user), :class => "remote-link", :title => "Sperren") 
    end
    
    # Organisation suspended?
    if user.suspended?            
      html << link_to(image_tag("fam-icons/add.png"), reactivate_admin_user_path(user), :class => "remote-link-put", :title => "Wieder aktiv schalten") 
    end
    
    html << link_to(image_tag("fam-icons/pencil.png"), edit_admin_user_path(user), :title => "Editieren") 
    html << link_to(image_tag("fam-icons/user_go.png"), simulate_admin_user_path(user), :method => :put, :title => "Simulieren")     
    html << link_to(image_tag("fam-icons/lightbulb_off.png"), "#detail-#{user.object_id}", :class => "admin-more-link", :title => "Details") 

    html    
  end
  
  
end
