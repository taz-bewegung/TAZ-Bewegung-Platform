# Let's use a custom form builder instead of our own wrappers around every form method.
# Rails makes it easy to use a different "Builder" for a form. In this class we
# create our own one and override the default form helpers.

class EditFormBuilder < ActionView::Helpers::FormBuilder
  include ActionController::Routing
  
  attr_accessor :use_divs
  
  helpers = field_helpers +
            %w{date_select datetime_select time_select} +
            %w{collection_select select country_select time_zone_select} -
            %w{hidden_field label fields_for} # Don't decorate these

  helpers.each do |name|
    
    # Meta programming galore: For all helpers in the helpers array we "define" a method with that name and
    # override the former one. We call "super" at the end to include the stuff from the former method.
    define_method(name) do |field, *args|
      # Extract options from hash
      options = args.extract_options!
      options['method_name'] = name
      
      # Build options
      options = build_options(options, field)

      # Get rid of unoppropriate options
      options.delete_if { |key, value| not [:include_blank, :style, :rel, :rows, :cols, :class, :multiple, :title, :id, :name, :maxlength, :value, :type, :size, :"data-update", :"data-href", :"data-disable"].include?(key.to_sym)}      
      
      # Build html
      wrap_field(super, field, options)
    end
    
  end
  
  def initialize(object_name, object, template, options, proc)
    self.use_divs = true if options[:use_divs] == true
    super
  end  
  
  def text(field, options = {})
      options = build_options(options, field)

      # Create content
      html = @template.v(@object.send(field))

      # Build html
      wrap_field(html, field, options)    
  end
  
  def localized_country_select(field, highlight, options = {}) 
    options = build_options(options, field)    
    options['method_name']  = 'localized_country_select' 
    html = @template.localized_country_select(@object.class.to_s.underscore, field, highlight, options)     

    # Get rid of unoppropriate options
    options.delete_if { |key, value| not [:rel, :class, :style, :id, :name, :value, :type, :title, :size].include?(key.to_sym)}      
    
    wrap_field(html, field, options)                
  end
  
  # An image field for forms to upload
  def image_field(field, options = {})        
    # Build options
    options = build_options(options, field)    
    options['method_name'] = 'image_field'
    options.reverse_merge!(:image_size => :mini, :id => "image", :image_object => @object)
    # Create content
    html = @template.content_tag :span, 
                                 @template.image_for(options[:image_object], options[:image_size], :default_image_from => options[:default_image_from]),
                                 :id => "image-#{@object.object_id}",
                                 :class => "image-field"
    html << self.hidden_field(field, :id => options[:id])
    html << @template.link_to("Bild auswählen", 
                              @template.url_for(:controller => "/images", :action => "lightbox", 
                                                :image_input => options[:id], 
                                                :image_size => options[:image_size],
                                                :part => "image-#{@object.object_id}"), 
                              :class => 'remote-link chose-image')                                                         
                              
    if options[:delete_link] == true
      html << @template.content_tag(:span, :class => "remove-image-span") do
        " | " +
        @template.link_to("Bild löschen", "javascript:void(0);", :class => "remove-form-image", :rel => options[:id])
      end
    end
                              
    # Get rid of unoppropriate options
    options.delete_if { |key, value| not [:rel, :style, :class, :id, :name, :value, :type, :size].include?(key.to_sym)}      
    
    # Build html
    wrap_field(html, field, options)                                 
  end 
  
  def document_field(field, options = {})        
    # Build options
    options.merge!(:fancy_table => false, :tooltip => false)    
    options = build_options(options, field)    
    options['method_name'] = 'document_field'

    # Create content
    html = @template.content_tag :span, 
                                 @template.document_for(@object),
                                 :id => "document-#{@object.object_id}",
                                 :class => "document-field",
                                 :style => "line-height: 30px; float: left;"
    html << @template.hidden_field_tag(:document, @object.document.id) if @object.temp_document.blank? and not @object.document.blank?
    html << @template.hidden_field_tag(:document, @object.temp_document.id) unless @object.temp_document.blank?                                     
    html << @template.link_to(@template.image_tag("buttons/btn-small-edit.png"), 
                              @template.url_for(:controller => "/documents", :action => "new", :format => :lightbox, :part => "document-#{@object.object_id}"), 
                              :class => 'remote-lightbox', :style => 'float: right')
                              
    # Get rid of unoppropriate options
    options.delete_if { |key, value| not [:rel, :style, :class, :id, :name, :value, :type, :size].include?(key.to_sym)}      
    
    # Build html
    wrap_field(html, field, options)                                 
  end
  
  def color_field(field, options = {})
    options = build_options(options, field)    
    
    html = @template.content_tag :div, :style => "background-color: ##{@object.send(field)}; width: 100px; float: left; margin-right: 10px; height: 23px; display: block; border: 1px solid #ddd",
                                       :id => "#{@object.class.to_s.underscore}_#{field.to_s}_div" do
            self.hidden_field field 
           end
    html += @template.link_to "Auswählen", "#", :class => "color-selector chose-image", 
                                                :"data-div" => "#{@object.class.to_s.underscore}_#{field.to_s}_div",
                                                :"data-input" => "#{@object.class.to_s.underscore}_#{field.to_s}",
                                                :"data-value" => @object.send(field)

    # Get rid of unoppropriate options
    options.delete_if { |key, value| not [:rel, :class, :style, :id, :name, :value, :type, :title, :size].include?(key.to_sym)}      
    wrap_field(html, field, options)    
  end  
  
  private
  
    def build_options(options, field) 
      @use_tooltip, @required = false
      @type = @object.class.to_s.underscore
      @float_table = false; 
      @hide_label = false; 
      @label_value = ""      
      @div_class = ""
      
      @hide_label = true if options[:hide_label]
      @label_value = options[:label_value] if options[:label_value]      
      
      @div_class = options[:div_class] if options[:div_class]      
          
      # Before & After HTML
      @before_html = ''
      @after_html = ''
      @before_table_style = ''
      unless options[:before_html].blank? 
        @before_html = options[:before_html]
        @before_table_style = ' style="float:left"'
      end
      
       #float_table
      @float_table = true unless options[:float_table].nil?
      
      if @float_table == true then
        @before_table_style = ' style="float:left"'
      end
      
      #puts options.inspect
      
      unless options[:after_html].blank? 
        @after_html = options[:after_html]
      end
      
      @class = ''
      
      unless options[:class].blank? 
        @class = options[:class]
      end  
      
      @id = ''
      unless options[:id].blank? 
        @id = options[:id]
      end      
             
      # Use tooltips by default
      
      if(options[:tooltip].nil? or options[:tooltip] == true) then
        @use_tooltip = true
      else
        @use_tooltip = false
      end             
      
      @tooltip_class = options[:tooltip_class] || 'tooltip'
      
      
      if(options[:render_table].nil? or options[:render_table] == true) then
        @render_table = true
      else
        @render_table = false
      end
      
      @fancy_table = true if options[:fancy_table].nil? or options[:fancy_table] == true
      
      if(options[:fancy_table].nil? or options[:fancy_table] == true) then
        @fancy_table = true
      else
        @fancy_table = false
      end
      
      @class = options[:class] unless options[:class].nil?
      @required = true if options[:required] == true 
      @type = options[:labels_from].to_s.underscore unless options[:labels_from].blank?
      
      unless options[:labels_from].blank?
        @base_class = options[:labels_from]
      else
        @base_class = @object.class
      end
      
      if options[:valign].blank? then
         @valign = 'top'
      else
         @valign =  options[:valign]
      end
      
      @method_name =  @class
      #options[:method_name] unless options[:method_name].blank?
      #puts options[:method_name].inspect                                
      # Build tooltip
      if @use_tooltip == true then options.merge!({ :rel => "div.#{@object.class.to_s.underscore}_#{field.to_s}", :class => "#{@tooltip_class}  #{@class}" }) end
      options
    end
  
    def wrap_field(content, field, options)
      
      # Create tooltip message
      if I18n.translate(:"activerecord.attributes.#{@type}.#{field.to_s}_tooltip").to_s.present?
        tip = @template.content_tag :div,
                                    RedCloth.new(I18n.translate(:"activerecord.attributes.#{@type}.#{field.to_s}_tooltip").to_s).to_html, 
                                    :class => "tip "+ @class
      else
        tip = ""
      end

      # Catch errors if they exist
      unless self.error_message_on(field.to_s).blank?
        error = @template.content_tag :div, "#{@base_class.human_attribute_name(field.to_s)} #{self.error_message_on(field.to_s)}", :class => "error "+ @class
      end
      
      # Build tooltip with errors and tip
      unless @use_tooltip.blank?
        tooltip = @template.content_tag(:div, "#{error.to_s} #{tip.to_s}", :class => "#{@object.class.to_s.underscore}_#{field.to_s}"+" "+ @class, :style => "display: none;")
      end
      
      label_value = @label_value.present? ? @label_value : I18n.translate(:"activerecord.attributes.#{@type}.#{field.to_s}")
      
      # Build label
      label = label(field, 
                    "#{label_value}#{ @required ? "*" : ''}:")     
      label = '' if @hide_label
      
      # Put it all together
      table_class = self.error_message_on(field).blank? ?  'normal-input'  : 'error-input' 
      
      table_class += ' ' + @class unless @class.blank?
      
      if(@fancy_table == true) then
        fancy_table_content = '<table border="0" cellpadding="0" cellspacing="0" class="' + table_class + '"'+@before_table_style+'>
                         <tr>
                           <td valign="bottom" align="right" class="lo"></td>
                           <td class="mo" valign="bottom"></td>
                           <td class="ro" align="left"></td>
                         </tr>
                         <tr>
                           <td class="lm"></td>
                           <td class="form-content">' + content + '</td>
                           <td class="rm"></td>
                         </tr>
                         <tr>
                           <td valign="top" align="right" class="lu"></td>
                           <td valign="top" class="mu"></td>
                           <td valign="top" align="left" class="ru"></td>
                         </tr>
                         </table>'
      else
        fancy_table_content = content
      end
      
      if @render_table == true
        
        if self.use_divs 
                
          input = @template.content_tag :div, :id =>  "#{@object.class.to_s.underscore}_#{field.to_s}_wrap",
                                    :class => "form-item-wrap #{@div_class}" do
            @template.content_tag(:div, "#{label}&nbsp;", :class => "form-item-label") +
            @template.content_tag(:div, @before_html + fancy_table_content + @after_html, :class => "form-item-input") +
            tooltip.to_s
          end
          
        else
        
          input = '<tr id="' + @object.class.to_s.underscore + '_' + field.to_s + '_wrap">
                   <th valign="'+ @valign +'" nowrap="nowrap">'+ label + '</th>
                     <td valign="'+ @valign +'" class="input-area">'+@before_html+ fancy_table_content + @after_html +'
                       '+ tooltip.to_s + '</td></tr>'
        end
      else                 
        input = label + @before_html+ fancy_table_content + @after_html + tooltip.to_s
      end
      
      input
      
    end
  
end