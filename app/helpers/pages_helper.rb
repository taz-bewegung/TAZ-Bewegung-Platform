module PagesHelper

	def static_sub_menu_items
		items = []                    
			items << { :name => 'Was ist Helpedia',
					:submenuitems => [
						{ :name => 'Wir über uns', :link_to => { :controller => "pages", :action => "ueber_uns"}, :id => :ueber_uns  },
						{ :name => 'Konzept', :link_to => { :controller => "pages", :action => "konzept"}, :id => :konzept  },
						{ :name => 'Selbstverständnis', :link_to => { :controller => "pages", :action => "selbstverstaendnis"}, :id => :selbstverstaendnis  },
						{ :name => 'Wie finanziert sich Helpedia?', :link_to => { :controller => "pages", :action => "finanzierung"}, :id => :finanzierung },
						{ :name => 'Was andere über uns sagen', :link_to => { :controller => "pages", :action => "was_andere_ueber_uns_sagen"}, :id => :was_andere_ueber_uns_sagen  },
						{ :name => 'Garantie', :link_to => { :controller => "pages", :action => "garantie"}, :id => :garantie  },
						{ :name => 'Danke', :link_to => { :controller => "pages", :action => "danke"}, :id => :danke  }
					]
			}

			
			items << { :name => 'Spenden & Sicherheit',
					:submenuitems => [
						{ :name => 'Wie funktioniert\'s', :link_to => { :controller => "pages", :action => "spenden"}, :id => :spenden  },
						{ :name => 'Sicherheit bei Helpedia', :link_to => { :controller => "pages", :action => "sicherheit_bei_helpedia"}, :id => :sicherheit_bei_helpedia  },
						{ :name => 'Spendenvorteile', :link_to => { :controller => "pages", :action => "spendenvorteile"}, :id => :spendenvorteile  }
				]
			}
			
			items << { :name => 'Informationen für Aktive',
					:submenuitems => [
						{ :name => 'Vorteile', :link_to => { :controller => "pages", :action => "vorteile_fuer_den_aktiven"}, :id => :vorteile_fuer_den_aktiven  },
						{ :name => 'Hinweise', :link_to => { :controller => "pages", :action => "hinweise_fuer_den_aktiven"}, :id => :hinweise_fuer_den_aktiven  }
					]
			}
			
			
			items << { :name => 'Informationen für Organisationen',
					:submenuitems => [
						{ :name => 'Vorteile', :link_to => { :controller => "pages", :action => "vorteile_fuer_organisationen"}, :id => :vorteile_fuer_organisationen  },
						{ :name => 'Hinweise', :link_to => { :controller => "pages", :action => "hinweise_fuer_organisationen"}, :id => :hinweise_fuer_organisationen  }
				]
			}			
						
			items << { :name => 'Beirat & Partner', :class => 'last',
					:submenuitems => [
						{ :name => 'Beirat & Mentor', :link_to => { :controller => "pages", :action => "beirat_und_mentor"}, :id => :beirat_und_mentor  },
						{ :name => 'Partner', :link_to => { :controller => "pages", :action => "netzwerk_partner"}, :id => :netzwerk_partner  }
				]
			}
			

	  
		items
	end

	def static_sub_menu(active)
		render :partial => "/menu/content_menu", :locals => { :menu_items => static_sub_menu_items, :active => active}
	end
end
