module NewsHelper

  def news_sub_menu_items
    items = []                    
    items << { :name => 'News',
                 :submenuitems => [
                   { :name => 'Newsübersicht', :link_to => news_path, :id => :news_list }
                 ]
               }
               
   items << { :name => 'Presse',
               :submenuitems => [
                 { :name => 'Ansprechpartner / Downloads', :link_to => press_path, :id => :press },                                                
#                 { :name => 'Pressemeldungen', :link_to => url_for(:controller => 'press', :action => 'categories', :id => 'pressemeldungen'), :id => :pressemeldungen },                                  
                 { :name => 'Onlinemedien über Helpedia', :link_to => press_category_path(:id => 'onlinemedien'), :id => :onlinemedien },
                 { :name => 'Printmedien über Helpedia', :link_to => press_category_path(:id => 'printmedien'), :id => :printmedien }                 
               ]
             }               
               
#    items << { :name => 'News-Archiv',
#                  :submenuitems => [
#                    { :name => '2009', :link_to => admin_organisations_path, :id => :news_2009  },
#                    { :name => '2008', :link_to => admin_organisations_path, :id => :news_2008, :class => "last"  }                    
#                  ]
#              }                                            
    items
  end

  def news_sub_menu(active)
    render :partial => "/menu/content_menu", :locals => { :menu_items => news_sub_menu_items, :active => active}
	end

end
