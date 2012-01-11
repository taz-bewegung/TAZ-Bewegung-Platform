module Content::ContentsHelper 
  
  # Renders content on home page
  def render_home_content_container(shortcut, options = {})
    container = ContentContainer.find_by_shortcut(shortcut)
    if container.nil?
      container = ContentContainer.create :shortcut => shortcut
      content = container.content_elements.create
      content.element = Content::TeaserText.new
      content.element.title = ""
      content.element.bodytext = '<div id="flash_player_container">You must enable JavaScript and install the <a href=\'http://www.flash.com\'>Flash</a> plugin to view this player</div><script type="text/javascript">
      //<![CDATA[
      var swf_obj = new SWFObject(\'/swf/player.swf\',\'jw_player\',\'279\',\'238\',\'9\');swf_obj.addParam(\'flashvars\',\'image=%2Fimages%2Fvideo-teaser.png&file=%2Fvideo%2Fbewegung.flv\'); swf_obj.addParam(\'quality\',\'autohigh\'); swf_obj.addParam(\'menu\',\'false\'); swf_obj.addParam(\'width\',\'279\'); swf_obj.addParam(\'allowfullscreen\',\'true\'); swf_obj.addParam(\'scale\',\'default\'); swf_obj.addParam(\'allowscriptaccess\',\'true\'); swf_obj.addParam(\'play\',\'true\'); swf_obj.addParam(\'height\',\'238\');swf_obj.write(\'flash_player_container\');
      //]]>
      </script>'
      content.save
    end

    html = ""
    for content in container.content_elements
      #html +=  render(:partial => content.element.class::PUBLIC_TEMPLATE, :locals => { :content => content, :elements => container.content_elements, :options => options })
    end
    html
  end  
  
  
  
  # Renders a content container and its elements.
  def render_content_container(shortcut, options = {})
    container = ContentContainer.find_by_shortcut(shortcut)

    html = ""
    for content in container.content_elements
      # FIXME
      #html +=  render(:partial => content.element.class::PUBLIC_TEMPLATE, :locals => { :content => content, :elements => container.content_elements, :options => options })
    end
    html
  end
  
  # Renders the carousel on the langing pages
  def render_carousel_container(shortcut, options = {})
    container = ContentContainer.find_by_shortcut(shortcut)
    options.reverse_merge!(:image_size => "393x197c")
    objects = [] 
    offset = 0
    
    container.content_elements.each do |content_element|
      next if content_element.element.hide_at.present? and content_element.element.hide_at < Date.tomorrow
      
      # Fetch each object individually
      tab_content = content_element.element
      
      if tab_content.latest?
        el = tab_content.element_type.to_class.find_latest_for_teaser_elements(offset)
        unless el.blank?
          objects << el
          offset += 1
        end
      elsif tab_content.element_id.present?
        objects << tab_content.element
      end
      
    end
    render :partial => "/content/landing_page/carousel", :locals => { :container => container, :objects => objects, :options => options }
  end 
  
  def render_start_carousel_container(shortcut, options = {})
    container = ContentContainer.find_by_shortcut(shortcut)
    Rails.logger.info container.content_elements.inspect
    html = render :partial => "/content/start_page/carousel", :locals => { :elements => container.content_elements, :container => container, :options => options }
    html
  end
  
  def render_top_container(shortcut)
    container = ContentContainer.find_by_shortcut(shortcut)
    if container.nil?
      container = ContentContainer.create :shortcut => shortcut
      content = container.content_elements.create
      content.element = Content::TopElement.new
      content.element.title = "Blogeintrag der Woche"
      content.element.element = BlogPost.last
      content.save  
    end

    html = ""
    for content in container.content_elements
      html += render :partial => "/content/start_page/top_element", :locals => { :content => content }
    end
    html
  end  
  
 
end
