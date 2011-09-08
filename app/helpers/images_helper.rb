module ImagesHelper 

  def image_sub_menu_items
    items = []                    
    items << { :name => "Bild hochladen", 
               :link_to => new_image_path(:part => params[:part], 
                                          :image_size => params[:image_size],
                                          :multiple => params[:multiple],
                                          :image_input => params[:image_input]), 
               :id => :new,
               :options => { :class => "ajax-link" } }
    items << { :name => "Mein Bild-Archiv", 
              :link_to => images_path(:part => params[:part],
                                      :image_size => params[:image_size],
                                      :multiple => params[:multiple],
                                      :image_input => params[:image_input]), 
              :id => :index,
              :options => { :class => "ajax-link" } }               
    items    
  end
  
  def image_sub_menu(active, options = {})
    render :partial => "/menu/sub_menu", :locals => { :menu_items => image_sub_menu_items, :active => active }
  end

  
  # Renders the image with an icon in the upper right corner to remove the parent div from the page.
  def form_image(image, size)
    html = link_to_function image_tag("icons/image-delete.gif"), "$(this).parent().remove();", :class => "image-delete-icon", :style => "position: absolute; right: 0px; top: 0px"
    html << image_tag(image.public_filename(size), :width => image.size_for_thumbnail(size).width, 
                                                   :height => image.size_for_thumbnail(size).height)    
  end
  
  
end
