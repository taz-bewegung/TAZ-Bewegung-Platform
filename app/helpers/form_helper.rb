module FormHelper 
  
  # Renders the footer for a form.
  def form_footer(options = {}, &block)
    options.reverse_merge!(:class => "w-140")
    concat '<div class="form-footer">
      <table border="0" class="reg-form ' + options[:class] + '">
        <tr>
          <th>
          </th>
          <td>' + capture(&block) + '</td>
      </table>
    </div>'
  end
  
  ### DEPRECATED ###
    
  def error_title_for(*params)    
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    count = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      content_tag(:div, t(:"shared.form.error-title-message"), :class => "error-title-message")
    end    
  end
  
  def label_for(form, method, options = {})
    options = options.stringify_keys
    options['klass'].blank? ? object = form.object.class : object = options['klass']
    options['required'] == true ? add = "*" : add = "" 
    form.label method.to_s, "#{object.human_attribute_name(method.to_s)}:#{add}"
  end

  def label_tag_for(method, options = {})
    options = options.stringify_keys
    object = options['klass']
    options['required'] == true ? add = "*" : add = "" 
    label_tag method.to_s, "#{object.human_attribute_name(method.to_s)}:#{add}"
  end     
  
  
  def select_for(form,method,options = {})
     
    tooltip, object, options = convert_options(options, method, form)
    logger.debug('Tooltip Obj: ' + object.to_s)
    unless options['include_blank'].blank?
      select_options = { :include_blank => options['include_blank']}
    else
      select_options = {}
    end
    #logger.debug(select_options)
    #logger.debug(tooltip)
    select = form.select(method,options['select_options'], select_options, options)
    
    
    unless form.error_message_on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{form.error_message_on(method.to_s)}", :class => "error"
    end
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
      logger.debug("Tooltip Object: ")
      
      logger.debug(object)
    end
    
    html = ''
    html << select
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s}")
  end
  
  
  def form_row_for(form, method, options = {})
    tooltip, object, options = convert_options(options, method, form)
    
    label = '<tr><th valign="top" nowrap="nowrap">' + object.human_attribute_name(method.to_s) + '</th>'
    label = '<tr><th valign="top" nowrap="nowrap">' + label_for(form, method, :required => true, :klass => object) + '</th>'
    
    case options['type']
      when 'input'
        field_content = text_field_for(form, method, :tooltip => true, :klass => object)
      when 'select'
        #field_content = form.select(method, options['select_options'], { :include_blank =>  t(:"shared.form.select.blank") }, :class => "tooltip", :title => "Test")
        field_content = select_for(form,method,options)
      when 'select2'
        field_content = select_for(form,method,options)
      when 'password' 
        field_content = password_field_for(form, method, :tooltip => true, :klass => object)
      when 'textarea'
        field_content = text_area_for(form, method, :tooltip => true, :klass => object)
    end
    
    
    
    
    if(options['beforeHTML'])
      beforeHTML = options['beforeHTML']
    else
      beforeHTML = ''
    end
    
    
    if(options['afterHTML'])
      afterHTML = options['afterHTML']
    else
      afterHTML = ''
    end
      
    if(options['wrap_field']==false)
      label = '' 
      field = field_content + afterHTML
    else
      logger.debug(method);
      logger.debug(form.error_message_on(method));
      
      table_class = form.error_message_on(method).blank? ?  'normal-input' : 'error-input' 
        
        
        
      field = '<td valign="middle" class="input-area">
             <table border="0" cellpadding="0" cellspacing="0" class="' + table_class +'">'+beforeHTML+'
                                            <tr>
                                                <td valign="bottom" align="right" class="lo">
                                                </td>
                                                <td class="mo" valign="bottom">
                                                </td>
                                                <td class="ro" align="left">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="lm">
                                                </td>
                                                <td>' + field_content + '</td>
                                                <td class="rm">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top" align="right" class="lu">
                                                </td>
                                                <td valign="top" class="mu">
                                                </td>
                                                <td valign="top" align="left" class="ru">
                                                </td>
                                            </tr>
                                        </table>' + afterHTML + '
                                    </td></tr>'
      end
    return html = label + field
    #logger.debug(name.inspect)
  end
  
  def text_field_for(form, method, options = {})
    
    tooltip, object, options = convert_options(options, method, form)
    
    logger.debug("FORM: " + form.inspect)
    
    input = form.text_field method.to_s, options
    
    unless form.error_message_on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{form.error_message_on(method.to_s)}", :class => "error"
    end
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
    end
    
    html = ''
    html << input
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s}")
  end
  
  def text_field_tag_for(method, options = {})
    tooltip, object, options = convert_options(options, method)
    options.merge!({ :name => "#{object.to_s.underscore}[#{method.to_s}]" })
    input = text_field_tag object, method.to_s, options  
    instance = instance_variable_get("@#{object.to_s.underscore}")
    unless instance.errors.on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{instance.errors.on(method.to_s)}", :class => "error"
    end 
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
    end
    
    html = ''
    html << input
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s} tip-wrapper")
  end  
  
  
  
  def password_field_for(form, method, options = {})
    
    tooltip, object, options = convert_options(options, method, form)
    input = form.password_field method.to_s, options
    
    unless form.error_message_on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{form.error_message_on(method.to_s)}", :class => "error"
    end
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
    end
    
    html = ''
    html << input
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s}")
  end  
  
  def text_area_for(form, method, options = {})
    tooltip, object, options = convert_options(options, method, form)
    input = form.text_area method.to_s, options
    
    unless form.error_message_on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{form.error_message_on(method.to_s)}", :class => "error"
    end
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
    end
    
    html = ''
    html << input
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s}")
  end
  
  def check_box_for(form, method, options = {})
    tooltip, object, options = convert_options(options, method, form)
    input = form.check_box method.to_s, options
    
    unless form.error_message_on(method.to_s).blank?
      error = content_tag :div, "#{object.human_attribute_name(method.to_s)} #{form.error_message_on(method.to_s)}", :class => "error"
    end
    
    unless tooltip.nil?
      tip = tooltip_for(object, method)
    end
    
    html = ''
    html << input
    html << content_tag(:div, "#{error} #{tip}", :class => "#{object.to_s.underscore}_#{method.to_s}")
  end  
  
    
     
  private
  
    def tooltip_for(object, method)
      tip = RedCloth.new(t(:"activerecord.attributes.#{object.to_s.underscore}.#{method.to_s}_tooltip")).to_html
      content_tag :div, tip, :class => "tip"
    end
  
    def convert_options(options, method, form = nil)
        
      options = options.stringify_keys
      tooltip = options['tooltip'] unless options['tooltip'].blank?
      object = options['klass'] unless options['klass'].blank? 
      
      #Hmm, select elements get tooltip_ + x id????
      #options.delete('tooltip')
      #options.delete('class')
      options.delete('klass')
      options.delete('tooltip')
      object = form.object.class if object.blank?
    
      unless tooltip.blank?
        options.merge!({ "rel" => "div.#{object.to_s.underscore}_#{method.to_s}", "class" => "tooltip" })
        options['class'] = "tooltip"
      end
  
      return tooltip, object, options
    end
 
end