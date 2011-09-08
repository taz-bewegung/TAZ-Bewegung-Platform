module Admin::TextsHelper
  
  attr_accessor :kept_keys
  
  def render_to_form(object)
    
    if object.is_a?(Hash)
      object = object.sort.each {|key, value| { key => value } }
    end
    
    if @kept_keys.blank?
      @kept_keys = Array.new
    end
    html = ""
    object.each do |key, value| 
      @kept_keys << key 
      if value.is_a?(Hash) or value.is_a?(Array)
        html += "<b>#{key}</b>" + "<ul><li>"
        html += render_to_form(value)
        html += "</li></ul>"
      else
        html += "<li> <label>#{key}:</label>" + text_area(:text, "", :name => ("text" + @kept_keys.map { |val| "[#{val}]" }.to_s), 
                                                                     :value => value,
                                                                     :class => "resizable",
                                                                     :id =>  @kept_keys.join("_")) + "</li>"
        @kept_keys.pop        
      end
    end
    @kept_keys.pop
    html
  end 
 
end 
