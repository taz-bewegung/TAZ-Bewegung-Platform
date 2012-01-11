# encoding: UTF-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper 
  
  #WillPaginate::ViewHelpers.pagination_options[:previous_label] = '&laquo; zurück'
  #WillPaginate::ViewHelpers.pagination_options[:next_label] = 'weiter &raquo;'
  
  def small_finder(context)
    content_for :finder do
      render :partial => "menu/small_finder", :locals => { :type => context}
    end
  end
  
  # Shows a lightbox on page load with given content.
  def show_lightbox_onload(options = {}, &block)
    options.reverse_merge!({ :selector => "show-remote-lightbox" })
    concat(
    content_tag(:div, :id => options[:selector], :style => "display: none") do
      yield
    end
    )
  end    
  
  def right_column(content)
    content_for(:right_column) { content }
  end  
  
  def use_googlemaps
    content_for :googlemaps do 
      #html = GMap.header 
      #html << javascript_include_tag("clusterer")
    end
  end  

  def auto_discovery_link(format, url_options = {}, html_options = {})
    content_for(:auto_discovery_link) { auto_discovery_link_tag(format, url_options, html_options) }
  end  
  
  def date_time_for(date)
    unless date.blank?
      l(date)
    else
      "-"
    end
  end           
  
  def rss_feed(path, title)
    content_for(:rss_feed){
      "<link href='#{path}' rel='alternate' title='#{title}' type='application/rss+xml' />".html_safe
    }
  end
    
  def time_span_or_time(date, options = {})
    options.reverse_merge!(:time_span => 1.day)
    if date.to_time > Time.now - options[:time_span]
      "vor #{distance_of_time_in_words_to_now(date)}"
    else
      options.delete :time_span
      l(date, options)
    end
  end
  
  def font_size_for_title(title)
    case title.length
    when 0..20 
      'style="font-size: 21px"'      
    when 20..30 
      'style="font-size: 16px"'
    when 30..40 
      'style="font-size: 14px"'
    when 50..60 
      'style="font-size: 12px; line-height: 13px; padding-top: 8px; margin-bottom: 2px;"'      
    when 70..90 
      'style="font-size: 11px; line-height: 12px; padding-top: 10px; margin-bottom: 0px;"'      
    when 90..120 
      'style="font-size: 10px; line-height: 11px; padding-top: 11px; margin-bottom: -1px;"'      
    else
      'style="font-size: 9px; line-height: 10px; padding-top: 12px; margin-bottom: -2px;"'          
    end      
  end
  
  def time_span_for(object, options = {})
    options.reverse_merge!(:mode => :time)

    if object.respond_to?(:"continuous?")
      "fortlaufend"
    elsif object.starts_at == object.ends_at
      l(object.starts_at.send("to_#{options[:mode]}"))
    elsif object.start_date == object.end_date
      
      html = object.start_date
      html << ", #{object.start_time} Uhr" unless object.start_time.blank?
      html << " - #{object.end_time} Uhr" unless object.end_time.blank?
      html
    else
      html = object.start_date
      html << ", #{object.start_time} Uhr" unless object.start_time.blank?
      html << " - #{object.end_date}"
      html << ", #{object.end_time} Uhr" unless object.end_time.blank?
      
      html
    end
  end
  
  
  # Sizes/Styles
  # * 35 (red)
  # * 39 (red)
  # * 60 (red)
  # * 33-beige
  def custom_form_button(label, options = {})
    options.reverse_merge!({:size => "35"})        
    content_tag :button, :type => "submit", :class => "custom-button-#{options[:size]}" do
      content_tag(:span, :class => "left") do
          concat content_tag(:span, label, :class => "normal")
          concat content_tag(:span, label, :class => "shadow")
      end
    end
  end
  
  
  def log_error(message)
    File.open(RAILS_ROOT + '/log/custom_errors.log', 'a+') {|f| f.write(Time.now.to_s + ", " + request.url + ", " + message + "\n") }
    nil
  end
  
  
  def custom_link_button(label, target = "#", options = {}, html_options = {})
    options.reverse_merge!({ :size => 35 })
    html_options.reverse_merge!({ :class => "custom-button-#{options[:size]}", :href => target })

    content_tag :a, html_options do
      content_tag(:span, :class => "left") do
          concat content_tag(:span, label, :class => "normal")
          concat content_tag(:span, label, :class => "shadow")
      end
    end
    
  end
  
  def shadow_form_button(label, options = {})
    options.reverse_merge!({ :size => 35 })
    html_options = {}
    
    content_tag :button, :type => "submit", :class => "shadow-form-button-#{options[:css_class]}" do
     concat content_tag(:span, shadow_text(label, options), :class => "left") 
     concat content_tag(:span, label, :class => "fallback-button-text")
    end
  end  
  
  def shadow_link_button(label, target = "#", options = {}, html_options = {})
    options.reverse_merge!({ :size => 35 })
    html_options.reverse_merge!({ :class => "#{options[:class]} shadow-button-#{options[:css_class]}", :href => target })
    content_tag :a, html_options do
      content_tag(:button, :class => "left") do
        label
      end
    end
  end
  
  
  # Strips out all html tags for xss prevention.
  # Links like "http://www.domain.com" are transfered into real links.
  def secure_formatted_text(text)
    simple_format(auto_link(h(sanitize(text))))
  end 
  
  # Sanitizes the +text+ and only leaves some tags. If the plain-option is 
  # set to true, all tags are stripped out.
  def secured_rte_text(text, options = {})
    options.reverse_merge!(:plain => false)
    tags = options[:plain] == true ? [] : %w(p a br ul ol li strong b em img object param embed a)
    sanitized_text = sanitize(auto_link(text, :href_options => {:target => "_blank"}), :tags => tags,
                                                                                       :attributes => %w(alt frameborder title name value href data width height type src allowfullscreen allowscriptaccess))
    html = ''
    unless options[:plain] == true
      html << content_tag(:span, :class => "rte-wrapper") do
              sanitized_text
            end
    else
      html << sanitized_text
    end
    html
  end
  
  def secured_video_code(code, options = {})
    options.reverse_merge!({:small => true})
    doc = Nokogiri::HTML(code)
    doc.search("iframe, embed, object").each { |element|
                                                      element.set_attribute("width", "170") if options[:small] == true
                                                      element.set_attribute("height", "115") if options[:small] == true
                                                      }
    
    code = sanitize(doc.at_css("body").inner_html, :tags => %w(object param embed a iframe img), :attributes => %w(name frameborder value href data width height type src allowfullscreen allowscriptaccess))
    doc = Nokogiri::HTML(code).search("iframe:first")
    if doc.length == 1
      secured_iframe_code(doc.first)
    else
      #code
      sanitize(code, :tags => %w(object param embed a img), :attributes => %w(name value href data width height type src allowfullscreen allowscriptaccess))
    end
  end
  
  def secured_iframe_code(doc)
    host = URI.parse(doc.attributes["src"]).host
    doc.to_html if BlogContentVideoWithCode::ALLOWED_SITES.include?(host)
  end
  
  def render_flash
    html = ''
    flash.each do |key, msg|
      html << content_tag(:div, :id => "flash_#{key}") do
              content_tag(:div, msg, :class => "message")
      end
    end
    return html
  end
  
  # Renders a word for a boolean value
  def wordify_boolean(bool)
#    bool ? t(:"shared.boolean.yes") : t(:"shared.boolean.no")
    bool ? "Ja" : "Nein"
  end
  
  # Used for printing out values in tables. If the value doesn't exist, a - sign is used instead.
  def value_or_blank(value)
    value.blank? ? "-" : h(value)
  end  
  alias_method :v, :value_or_blank
  
  
  def filter_item(&block) 
    #content = yield
    content = capture(&block)
    render :partial => "/pagination_filter/item", :locals => { :content => content }
  end
  
  def pagination_filter(collection)
    render :partial => "/pagination_filter/pagination", :locals => { :collection => collection }
  end
  
  def filter_select(type, span_label, &block)
      active_filter = content_tag :div, :class => "active-filter" do
        content_tag(:span, span_label) + 
        content_tag(:span, :class => "hover-span") do
        link_to("", "#", :class => "act-filter-item") + image_tag("pagination-filter/arrow-bottom.png") + filter_item { yield }
      end
    end
    content = content_tag :div, :class => "item #{type}", :"data-id" => type do
      active_filter + spinner("")
    end
    concat(content)
  end
  
  def filter_search_select(type, span_label, &block)
      active_filter = content_tag :div, :class => "active-filter" do
        content_tag(:span, span_label) + 
        content_tag(:span, :class => "hover-span") do
        yield
      end
    end
    content = content_tag :div, :class => "item #{type}", :"data-id" => type do
      active_filter + spinner("")
    end
    concat(content)
  end
  
  
  # Layout switcher
  def layout_icons(active, urls)
    icons = []
    %w( tiny cards rows maps cal ).each do |icon|
      next if urls[icon.to_sym].blank?
      if active == icon.to_sym
        icon_class =  "act #{icon}"
        image = image_tag "pagination-filter/icon-#{icon}-hover.png"
      else
        icon_class = "#{icon}"
        image = image_tag "pagination-filter/icon-#{icon}.png"
      end
      icons << content_tag(:li, link_to(image + I18n.t(:"pagination_filter.filter.#{icon}"), urls[icon.to_sym], :"data-value" => icon), :class => icon_class)
    end
    content_tag :ul, icons.join(""), :class => "layout_icons"
  end 
  
  def next_pagination_link(collection, title, options = {})
    options[:class] = options[:class].to_s + " next"
    if collection.total_pages == params[:page]
      next_page = params[:page]
    else 
      next_page = params[:page].to_i+1
    end
    link_to title, url_for(params.merge!(:page => next_page)), options
  end
  
  def first_pagination_link(collection, title, options = {})
    options[:class] = options[:class].to_s + " first"
    first_page = 1
    link_to title, url_for(params.merge!(:page => first_page)), options
  end
  
  def last_pagination_link(collection, title, options = {})
    options[:class] = options[:class].to_s + " last"
    last_page = collection.total_pages
    link_to title, url_for(params.merge!(:page => last_page)), options
  end  
  
  def previous_pagination_link(collection, title, options = {})
    options[:class] = options[:class].to_s + " previous"
    if params[:page] == 1
      next_page = params[:page]
    else 
      next_page = params[:page].to_i-1
    end
    link_to title, url_for(params.merge!(:page => next_page)), options
  end

  # Layout switcher
  def layout_switch_icons(active, options = {})

    options.reverse_merge!({ :spinner => "table-spinner", :ajax_reloaded => false })
    
    active == :rows  ? list_act = "act" : list_act = ''
    active == :cards ? card_act = "act" : card_act = ''
    active == :maps  ? maps_act = "act" : maps_act = ''
    active == :cal   ? cal_act = "act" : cal_act = ''
    active == :tiny  ? tiny_act = "act" : tiny_act = ''    

    split = image_tag("tab_view_controller/general/trenner.png")    
    
    icons = []
    
    icons << link_to(" ", options[:list], :class => "list #{list_act}", :id => "rows", :rel => options[:spinner]) if options.include?(:list)
    icons << link_to(" ", options[:tiny], :class => "tiny #{tiny_act}", :id => "tiny", :rel => options[:spinner]) if options.include?(:tiny)
    icons << link_to(" ", options[:card], :class => "card #{card_act}", :id => "cards", :rel => options[:spinner]) if options.include?(:card)
    icons << link_to(" ", options[:cal], :class => "cal #{cal_act}", :id => "cal", :rel => options[:spinner]) if options.include?(:cal)
    icons << link_to(" ", options[:maps], :class => "maps #{maps_act}", :id => "maps", :rel => options[:spinner]) if options.include?(:maps)
    icons = icons.split(split)

    # Ajax reloaded means, that the icons are replaced by an ajax call. The javascript for setting
    # the act-classes should therefore not trigger.
    ajax_class = options[:ajax_reloaded] ? "ajax" : ""
    
    icon_div = content_tag :div, icons, :class => "list-switch-icons #{ajax_class}"
    html = content_tag :div, icon_div, :class => "list-switch-icon-wrap"    
  end   
  
  ##
  # More box
  # Blocks in view helpers see: http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  def more_filter_box(options = {}, &block)
    options.merge!(:content => capture(&block))
    concat(render(:partial => "/shared/more_filter_box", :locals => options), block.binding)
  end
  
  def pagination_for(objects, options = {})
    
    options[:previous_label] = options[:previous_label].blank? ? 'Prev' : options[:previous_label]
    options[:next_label] = options[:next_label].blank? ? 'Next' : options[:next_label]
    options[:first_label] = options[:first_label].blank? ? 'Anfang' : options[:first_label]
    options[:last_label] = options[:last_label].blank? ? 'Ende' : options[:last_label]
    options[:page_links].blank? ? 'default' : options[:page_links]
    options[:previous_links].blank? ? true : options[:previous_links]
    options[:next_links].blank? ?  true : options[:next_links]
    
    will_paginate objects, :previous_label => options[:previous_label],
                           :next_label => options[:next_label],
                           :renderer => CustomLinkRenderer,
                           :page_links => options[:page_links],
                           :previous_links => options[:previous_links],
                           :next_links => options[:next_links],
                           :first_label => options[:first_label],
                           :last_label => options[:last_label],
                           :params => options[:params]
                           
  end 
  
  def current_page(collection)
    current_page = params[:page] < 1 ? 1 : params[:page]
    total_pages = collection.total_pages < 1 ? 1 : collection.total_pages
    "#{current_page} / #{total_pages}"
  end
  
  def total_entries(collection)
    collection.total_entries
  end
  
  def total_pages(collection)
    collection.total_pages
  end
  
  def order_option_selected(order)
    'selected="selected"' if params[:order] == order
  end
  
  def website_link(url, text = nil)
    text = url if text.blank?
    protocol = url.include?("http") ? "" : "http://"
    link = link_to(h(text), "#{protocol}#{url}", :onclick => "window.open(this.href); return false;")  
  end
  
  def cache_fragment(cache_key, options = {}, &block)
    timestamp = CachingStats.date_for_key(cache_key)    
    options[:key_parts] = [] if options[:key_parts].blank?
    options[:key_parts] << timestamp
    options[:key_parts].insert(0, request.format.to_s)    
    key = "#{cache_key}/#{options[:key_parts].join('/')}"
    options.delete(:key_parts) unless options[:key_parts]
    cache(key, options, &block)    
  end
  
  # Cache or render_or_cacher if the user has a specific role 
  def render_or_cache(key, options = {}, cache_options = {}, &block)
    if options[:ignore_roles].present? and logged_in? and current_user.has_role?(options[:ignore_roles])
      yield
    else
      cache("#{Rails.env.to_s}_#{key}", cache_options, &block)
    end
  end  
  
  
  def spinner(id = "spinner")
    content_tag(:div,
                image_tag("ajax-spinner.gif", :class => "spinner"),
                :id => id,
                :class => "spinner",
                :style => "display:none"
    )
  end
  
  # Helper function for an endless page.
  # Used for the donations and the public stream.
  def pageless(total_pages, options = {})
    javascript_tag(
      "$('#{options[:element]}').pageless({" \
        "totalPages:#{total_pages}," \
        "url:'#{options[:url]}'," \
        "params:{without_layout: true}, " \
        "loaderMsg:'#{options[:message]}'," \
        "loaderImage: '/images/ajax-spinner.gif'" \
      "});")
  end
  
  # Helper methods for nested attribute forms
  # Taken from Railscasts #197 (http://railscasts.com/episodes/197-nested-model-form-part-2)
  def remove_child_link(name, f, options = {})
    f.hidden_field(:_delete) + link_to_function(name, "remove_fields(this)", options)
  end

  def add_child_link(name, f, options)
    options[:no_index] ||= false 
    html = render(:partial => options[:partial], :locals => { :form => f, 
                                                              :object => options[:object], 
                                                              :index => options[:index], 
                                                              :no_index => options[:no_index],
                                                              :tiny_mce_selector => options[:tiny_mce_selector] })
    where = "$(\"#{options[:where]}\")" || "this"
    tiny_mce = options[:tiny_mce] ? "true" : "false"
    tiny_mce_selector = options[:tiny_mce_selector] ? options[:tiny_mce_selector] : ""
    link_to_function(name, h("insert_fields(#{where}, \"#{options[:index]}\", \"#{escape_javascript(html)}\", #{tiny_mce}, \"#{tiny_mce_selector}\")"))      
  end  
  
  def md5(string) 
    Digest::MD5.hexdigest(string)
  end
  
  def tinyurl(url)
    uri = 'http://tinyurl.com/api-create.php?url=' + url
    uri = URI.parse(uri)
    tiny_url = Net::HTTP.get_response(uri).body
  end
  
  def twitter_link(url)
    link_to image_tag("socialmedia/16/twitter.png"), "http://twitter.com/home?status=Ich lese #{tinyurl(url)} bei bewegung.taz.de", :target => "_blank", :title => "Bei twitter veröffentlichen"
  end
    
end