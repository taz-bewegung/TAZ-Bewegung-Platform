module HeaderHelper

  def magick_header(text, options = {})
    content_for(:magick_header) {content_tag :h1, text}
  end
  
  def shadow_text(text, options = {})
    #image_tag MagickFontMaker.create_shadow_text(text, options)
    text
  end
  
  def shadow_text_filename(text, options = {})
    #MagickFontMaker.get_shadow_text_filename(text, options)
    text
  end
  
  def welcome_header(left, right)
    content_for(:magick_header) do
      "<h2><span style='float:left'>#{left}</span><span class='right'>#{right}</span></h2>".html_safe
    end
  end

end