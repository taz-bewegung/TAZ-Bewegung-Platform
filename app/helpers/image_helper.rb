module ImageHelper

  # Renders the image with an icon in the upper right corner.
  def archive_image(image, size)
    image.find_or_create_thumbnail(size)
    html = link_to image_tag("icons/image-delete.gif"), image_path(image), :class => "ajax-link-delete-image image-delete-icon", :style => "position: absolute; right: 0px; top: 0px"
    html << image_tag(image.public_filename(size), :width => image.size_for_thumbnail(size).width,
                                                   :height => image.size_for_thumbnail(size).height)
  end


  def image_for(object, size, options = {})
    html = ""

    # Show the context menu if required
    if options[:context_menu]
      html = view_context.context_menu_for(object, options[:context_menu])
    end

    if object.temp_image.blank? and not object.image.blank?

      # Try to find the thumbnail with the correct size. If the thumbnail does not exist, create it on the fly.
      object.image.find_or_create_thumbnail(size)

      image_html = view_context.image_tag(object.image.public_filename(size), :width => object.image.size_for_thumbnail(size).width,
                                                                            :height => object.image.size_for_thumbnail(size).height)
    elsif object.temp_image
      image = Image.find(object.temp_image)
      image_html = view_context.image_tag(image.public_filename(size), :width => image.size_for_thumbnail(size).width,
                                                               :height => image.size_for_thumbnail(size).height)
    else

      if File.exists?("#{Rails.root}/public/images/default/#{object.class.to_s.pluralize.downcase}/#{object.class.to_s.downcase}_#{size}.gif")
        image_html = view_context.image_tag "default/#{object.class.to_s.pluralize.downcase}/#{object.class.to_s.downcase}_#{size}.gif"
      else
        image_html = "<span class='noimage'> - </span>".html_safe
      end
    end

    # Link the image if we want to
    if options[:link_to]
      image_html = link_to image_html, options[:link_to]
    end

    html += image_html
    html.html_safe
  end

  alias_method :event_image_for, :image_for
  alias_method :organisation_image_for, :image_for
  alias_method :activity_image_for, :image_for
  alias_method :user_image_for, :image_for

  def image_url_for(object, size)
    unless object.image.blank?
      "http://#{request.host_with_port}" + object.image.public_filename(size)
    else
      "http://#{request.host_with_port}/images/default/#{object.class.to_s.pluralize.downcase}/#{object.class.to_s.downcase}_#{size}.gif"
    end
  end

  def context_menu_for(object, menu)
    html = menu
  end

end