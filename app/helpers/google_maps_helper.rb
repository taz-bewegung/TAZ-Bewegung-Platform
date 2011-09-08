module GoogleMapsHelper
  #include ActionView::Helpers::DateHelper
  include ::ApplicationHelper
  def build_map(collection, options = {})
   options.reverse_merge!({:large_map => true, :small_map => false, :map_type => true, :zoom => 5, :max_visible_markers => 100})
   @map = GMap.new("map_div")
   @map.control_init(:large_map => options[:large_map], :map_type => options[:map_type], :small_map => options[:small_map], :hierarchical_map_type => true)
   
   lat = options[:lat] || GEOCODE_DEFAULT_LOCATION["lat"]
   lng = options[:lng] || GEOCODE_DEFAULT_LOCATION["lng"]
   
   @map.center_zoom_init([lat, lng], options[:zoom])

#   @map.add_map_type_init(GMapType::G_PHYSICAL_MAP)
   @map.set_map_type_init(GMapType::G_PHYSICAL_MAP) 
   
   @map.clear_overlays
   @map.width = options[:width]
   @map.height = options[:height] 
         
    markers = []
    for item in collection
      # create markers for map
      icon = GIcon.new(
        :image => "/images/markers/gmaps-pint-#{item.class.to_s.downcase}.png",
        :iconSize => GSize.new(21, 21),
        :iconAnchor => GPoint.new(1, 1),
        :infoWindowAnchor => GPoint.new(1, 1),
        :infoShadowAnchor => GPoint.new(18, 25)
      )      
      marker = GMarker.new([item.address.lat, item.address.lng], 
                          :title => item.title, 
                          :info_window => self.send("#{item.class.to_s.downcase}_tooltip".to_sym, item),
                          :icon => icon)
      markers << marker
    end      
    clusterer = Clusterer.new(markers, :icon => icon, :max_visible_markers => options[:max_visible_markers])
    @map.overlay_init clusterer
  end
  
  def organisation_tooltip(organisation)
    @template.content_tag :div, :class => "info-window" do
      @template.content_tag(:div, @template.link_to(organisation.name, organisation_path(organisation)), :class => "title") +
      @template.content_tag(:div, @template.link_to(image_for(organisation, :mini), organisation_path(organisation)), :class => "image") +
      @template.content_tag(:div, :class => "address") do
        "<dt>Adresse:</dt><dd>#{organisation.address.to_html_long}</dd></dl>"
      end
    end
  end
  
  def activity_tooltip(activity)
    @template.content_tag :div, :class => "info-window" do
      @template.content_tag(:div, @template.link_to(activity.title, activity_path(activity)), :class => "title") +
      @template.content_tag(:div, @template.link_to(image_for(activity, :mini), activity_path(activity)), :class => "image") +
      @template.content_tag(:div, :class => "address") do
        "<dl><dt>Aktion von:</dt><dd>#{@template.user_profile_link_for(activity.owner)}</dd>" +
        "<dt>Adresse:</dt><dd>#{activity.address.to_html_long}</dd></dl>"
      end
    end
  end  
  
  def event_tooltip(event)

    @template.content_tag :div, :class => "info-window" do
      @template.content_tag(:div, @template.link_to(event.title, event_path(event)), :class => "title") + 
      @template.content_tag(:div, @template.link_to(image_for(event, :mini), event_path(event)), :class => "image") +
      @template.content_tag(:div, :class => "address") do
        "<dl><dt>Termin von:</dt><dd>#{@template.user_profile_link_for(event.originator)}</dd>" +
        "<dt>Zeitraum:</dt><dd>#{time_span_for(event)}" +
        "<dt>Adresse:</dt><dd>#{event.address.to_html_long}</dd></dl>"
      end
    end
  end

  def location_tooltip(location)
    @template.content_tag :div, :class => "info-window" do
      @template.content_tag(:div, @template.link_to(location.name, location_path(location)), :class => "title") +
      @template.content_tag(:div, @template.link_to(image_for(location, :mini), location_path(location)), :class => "image") +
      @template.content_tag(:div, :class => "address") do
        "<dt>Adresse:</dt><dd>#{location.address.to_html_long}</dd></dl>"
      end
    end
  end
  
end