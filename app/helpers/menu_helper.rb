module MenuHelper
  
  def top_menu_items
    items = []                     
    #items << { :name => 'Start', :link_to => root_path, :id => :start  }
    items << { :name => 'Termine', :link_to => events_path, :id => :events }
    items << { :name => 'Aktionen', :link_to => activities_path, :id => :activities }
    items << { :name => 'Organisationen', :link_to => organisations_path, :id => :organisations }                    
    items << { :name => 'Orte', :link_to => locations_path, :id => :locations }   
    items << { :name => 'Profil', :link_to => my_helpedia_path, :id => :my_helpedia }
    items
  end  
  
  
  def logo_class_for(item)
    'logo-' + item.to_s unless item.blank?
  end
  
  def css_class_for(item)
    act = @current_main_menu_id == item[:id] ? ' act'  : ' no '
    last = top_menu_items.last == item[:id] ? ' last ' : ''    
    return 'class="' + act  + last + '"'
  end
  
  def main_menu(id)
    @current_main_menu_id = id || :start
  end
  
  def title(title)
    content_for(:title) { title }     
  end
  
  def breadcrumb(items)
    html = items.join(" / ")
    content_for(:breadcrumb) { html } 
  end
  
  def edit_header(html)
    content_for(:edit_header) {html}
  end
  
  # Sub navigation
  def nav_sub_is_active?(item, active, items)
    
    css_class = ''
    css_class << 'first' if items.first == item
    css_class << 'act' if item[:id] == active 
    css_class << " #{item[:class]}" if item[:class]
    
    html = css_class.blank? ? "" : css_class = 'class="' + css_class + '"'
    html += 'style="' + item[:style] + '"' unless item[:style].blank?
    html
  end
  
  # Sub navigation
  def nav_content_is_active?(item, active, items)
    options = {}
    if item[:id] == active
      options[:class]  = "act"
    end
    options
  end  
  
end