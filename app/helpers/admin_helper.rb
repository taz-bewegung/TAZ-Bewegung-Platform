# encoding: UTF-8
module AdminHelper
  
  def admin_sub_menu_items
    items = []
    items << { :name => 'Aktivitäten',
                 :submenuitems => [
                   { :name => 'Was läuft gerade', :link_to => admin_feed_events_path, :id => :feed_events }, 
                 ]
               }    
    items << { :name => 'Benutzer',
                 :submenuitems => [
                   { :name => 'Benutzerliste', :link_to => admin_users_path, :id => :user_list  }, 
                   { :name => 'Beta-Anmelder', :link_to => admin_beta_users_path, :id => :beta_users  },
                   { :name => 'gesperrte Benutzer', :link_to => suspended_admin_users_path, :id => :suspended_users  },
                   { :name => 'Rollenübersicht', :link_to => admin_roles_path, :id => :user_roles  },
                 ]
               }
    items << { :name => 'Organisationen',
                  :submenuitems => [
                   # { :name => 'Organisationsliste Workaround ', :link_to => old_school_index_admin_organisations_path, :id => :organisation_list  },
                    { :name => 'Organisationsliste', :link_to => admin_organisations_path, :id => :organisation_list  },
                    { :name => 'wartende Organisationen', :link_to => not_activated_admin_organisations_path, :id => :new_organisations },                    
                    { :name => 'gesperrte Organisationen', :link_to => suspended_admin_organisations_path, :id => :suspended_organisations },                                        
                  ]
              }                                            

    items << { :name => 'Aktionen',
                 :submenuitems => [
                   { :name => 'Aktionssliste', :link_to => admin_activities_path, :id => :activity_list  },
                   { :name => 'gesperrte Aktionen', :link_to => suspended_admin_activities_path, :id => :suspended_activities },
                 ]
               }
        
    items << { :name => 'Termine',
					:submenuitems => [
						{ :name => 'Terminliste', :link_to => admin_events_path, :id => :event_list  },
            { :name => 'gesperrte Termine', :link_to => suspended_admin_events_path, :id => :suspended_events },
					]
		}		
		
    items << { :name => 'Orte',
					:submenuitems => [
						{ :name => 'Ortliste', :link_to => admin_locations_path, :id => :location_list  },
            { :name => 'gesperrte Orte', :link_to => suspended_admin_locations_path, :id => :suspended_locations },
					]
		}		
		

    items << { :name => 'Nachrichten',
					:submenuitems => [
						{ :name => 'Nachrichten', :link_to => admin_messages_path, :id => :messages  },
						{ :name => 'Neue Systemnachricht', :link_to => new_admin_message_path, :id => :new_message  },
					]
		}		
		
    items << { :name => 'Dateien',
					:submenuitems => [
						{ :name => 'Bilder', :link_to => "#", :id => :event_list  },
					]
		}		
		
    items << { :name => 'Statische Inhalte',
					:submenuitems => [
						{ :name => 'Labels', :link_to => admin_texts_path, :id => :texts  },
						{ :name => 'Seiten', :link_to => "#", :id => :event_statistics  }
					]
		}		

	  items
	end

	def admin_sub_menu(active)
		render :partial => "/menu/content_menu", :locals => { :menu_items => admin_sub_menu_items, :active => active}
	end
  
  
end
