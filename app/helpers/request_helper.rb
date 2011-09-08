module RequestHelper

  def contact_sub_menu_items
    items = []                    
    items << { :name => 'Kontakt',
                 :submenuitems => [
                   { :name => 'Kontaktformular', :link_to => new_request_path, :id => :contact_form },
                   { :name => 'Ansprechpartner', :link_to => contact_person_path, :id => :contact_people }                   
                 ]
               }
                            
    items
  end

  def contact_sub_menu(active)
    render :partial => "/menu/content_menu", :locals => { :menu_items => contact_sub_menu_items, :active => active}
	end  
  
  
  
end
