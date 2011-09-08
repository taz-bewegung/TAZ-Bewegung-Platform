module Admin::OrganisationsHelper
   
  # Lists the icons for an organisation.
  def organisation_icons_for(organisation)
    html = ""
    
    # Organisation pending?
    if organisation.pending?        
      html << link_to(image_tag("fam-icons/accept.png"), activate_admin_organisation_path(organisation), :method => :put, :title => "Freischalten") if organisation.address.present?
      html << link_to(image_tag("fam-icons/delete.png"), suspend_admin_organisation_path(organisation), :method => :put, :title => "Sperren")       
    end
    
    # Organisation active?
    if organisation.active?    
      html << link_to(image_tag("fam-icons/delete.png"), suspend_admin_organisation_path(organisation), :method => :put, :title => "Sperren") 
    end
    
    # Organisation suspended?
    if organisation.suspended?            
      html << link_to(image_tag("fam-icons/add.png"), reactivate_admin_organisation_path(organisation), :method => :put, :title => "Wieder aktiv schalten") 
    end
    
    html << link_to(image_tag("fam-icons/pencil.png"), edit_admin_organisation_path(organisation), :title => "Editieren") 
    html << link_to(image_tag("fam-icons/user_go.png"), simulate_admin_organisation_path(organisation), :method => :put, :title => "Simulieren")     
    html << link_to(image_tag("fam-icons/lightbulb_off.png"), "#detail-#{organisation.object_id}", :class => "admin-more-link", :title => "Details") 

    html    
  end
  
  def formal_organisation_status_for(organisation)
    case organisation.state
    when "pending" then content_tag(:span, "registriert", :class => "yellow")
    when "active" then content_tag(:span, "freigeschaltet", :class => "green")
    when "suspended" then content_tag(:span, "gesperrt", :class => "red")
    end
  end
  
  def notice_of_excemption_status_for(organisation) 
    if organisation.notice_of_excemption
      html = content_tag :span, wordify_boolean(organisation.notice_of_excemption), :class => "green"
      html << "<br />#{I18n.localize(organisation.notice_of_excemption_ends_on)}" unless organisation.notice_of_excemption_ends_on.blank?
      html << "<br />" + link_to_remote("Bearbeiten", :url => edit_admin_organisation_path(organisation), :method => :get)
    else
      html = content_tag :span, wordify_boolean(organisation.notice_of_excemption), :class => "red"
      html << "<br />#{I18n.localize(organisation.notice_of_excemption_ends_on)}" unless organisation.notice_of_excemption_ends_on.blank?
      html << "<br />" + link_to_remote("Bearbeiten", :url => edit_admin_organisation_path(organisation), :method => :get)
    end    
    html
  end
  
  
  
end
