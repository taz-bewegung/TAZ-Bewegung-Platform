module Admin::DonationsHelper

  # Lists the icons for an donations.
  def donation_icons_for(donation)
    html = ""
    html << link_to(image_tag("fam-icons/lightbulb_off.png"), "#detail-#{donation.object_id}", :class => "admin-more-link", :title => "Details") 
    html    
  end  
  
  def formal_donation_status_for(donation)
    if donation.elargio_donation? then return "" end
    html = ""
    if not donation.exported_at.blank? or not donation.viewed_at.blank? 
      html << content_tag(:span, " angesehen", :class => "green") if not donation.viewed_at.blank?      
      html << content_tag(:span, " heruntergeladen", :class => "green") if not donation.exported_at.blank?
    else
      html << content_tag(:span, "ungesehen", :class => "red")      
    end
    html
  end  
  
end
