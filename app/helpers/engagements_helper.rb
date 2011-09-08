module EngagementsHelper
  
  def engagement_sub_menu_items
    items = []                    
    items << { :name => 'Überblick', :link_to => engagement_path(@engagement), :id => :overview  }
    items << { :name => 'Beschreibung', :link_to => description_engagement_path(@engagement), :id => :description }
    items << { :name => 'Neuigkeiten', :link_to => engagement_blogs_path(@engagement), :id => :blog }                    
    items    
  end
  
  def engagement_sub_menu(active)
    render :partial => "/menu/sub_menu", :locals => { :menu_items => engagement_sub_menu_items, :active => active}
  end
  
  def engagement_period_for(engagement)
    if engagement.running?
      html = t(:"engagement.calculations.running_since", :date => l(engagement.starts_on.to_date))
    else
      html = "#{l(engagement.starts_on.to_date)} - #{engagement.ends_on.to_date}"      
    end
  end  
  
end
