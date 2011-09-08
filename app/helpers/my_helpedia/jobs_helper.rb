module MyHelpedia::JobsHelper

   def my_helpedia_job_sub_menu_items
      items = []                    
#      items << { :name => 'Übersicht', :link_to => my_helpedia_organisation_job_path(@organisation, @job), :id => :overview  }
      items << { :name => 'Jobprofil', :link_to => edit_my_helpedia_organisation_job_path(@organisation, @job), :id => :profile }
      items    
    end

    def my_helpedia_job_sub_menu(active)
      render :partial => "/menu/sub_menu", :locals => { :menu_items => my_helpedia_job_sub_menu_items, :active => active}
    end

end
