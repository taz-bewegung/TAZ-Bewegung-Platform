module DonationsHelper

    def donation_sub_menu_items
      items = []                    
      items << { :name => "1: Spenden", 
                 :id => :donate }
      items << { :name => "2: Deine Daten", 
                 :id => :userdata }
      items << { :name => "3: Zusammenfassung", 
                 :id => :preview }
      items << { :name => "4: Spendenquittung?", 
                :id => :finished }                 
      items    
    end

    def donation_sub_menu(active)
      render :partial => "/menu/sub_menu", :locals => { :menu_items => donation_sub_menu_items, :active => active}
    end  
  
end
