module JobsHelper
  
  def render_job_info_box(job, mode)
    if job.organisation == current_user
      case mode
      when :private
        page = "Job/Ehrenamt bearbeiten"
        message = ''
        link = link_to("Job/Ehrenamt anzeigen", job_url(job))
      when :public
        page = "Live-Ansicht"
        message = ''
        link = link_to("Job/Ehrenamt bearbeiten", my_helpedia_organisation_job_url(current_user, job))        
      end                                                          
      render :partial => "/shared/info_box", :locals => { :page => page,
                                                          :message => message,
                                                          :link => link }
    end
  end  
  
  def start_date_for(job)
    unless job.starts_on.nil?
      l(job.starts_on.to_date)    
    else
      "laufend"
    end
  end

  def job_sub_menu_items
    items = []                    
    items << { :name => "Anforderungen & Aufgaben", 
               :link_to => job_path(@job), 
               :id => :requirements  }
    items << { :name => "Wir bieten", 
              :link_to => contact_job_path(@job), 
              :id => :offer  }               
    items    
  end
  
  def job_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => job_sub_menu_items, :active => active}
  end
  
  
end
