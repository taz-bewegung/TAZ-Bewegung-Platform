class MagickFontMaker

  def self.create_magick_header(text, options = {})
    options.reverse_merge!({:gradient_from => "#b30834", :gradient_to => "#848071", :width => 650, :height => 50})
    path = "magick_headers/#{Digest::MD5.hexdigest(text + options.to_s)}.png"
    file = "#{Rails.root}/public/images/" + path
    unless File.exists?(file)
      image = Magick::Image.new(options[:width], options[:height]) {
        self.background_color = 'transparent'
        self.format = 'PNG'

      }
      gc = Magick::Draw.new
      gc.font = "#{Rails.root}/public/fonts/AvantGarde-Bold.ttf"
      gc.pointsize = 30
      #gc.stroke('transparent')
      gc.stroke_width(0)
      gradient = Magick::GradientFill.new(0, 0, 0, options[:height], options[:gradient_from], options[:gradient_to])
      stats = gc.get_type_metrics(image, text)
      bg_fill = Magick::Image.new(stats.width, options[:height], gradient)
      #gc.fill_pattern = bg_fill
      gc.text(0, (options[:height].to_i - 10), text)
      gc.draw(image)

      image.write(file)
    end

    path
  end

  def self.get_shadow_text_filename(text, options = {})

    options.reverse_merge!({:font_size => 14})
    path = "magick_button_text/#{Digest::MD5.hexdigest(text + options.to_s)}.png"
    path
  end

  def self.create_shadow_text(text, options = {})

    options.reverse_merge!({:font_size => 14})
    path = "magick_button_text/#{Digest::MD5.hexdigest(text + options.to_s)}.png"
    file = "#{Rails.root}/app/assets/images/" + path

    unless File.exists?(file)

      dummy = Magick::Image.new(500,100)

      header = text
      gc = Magick::Draw.new
      gc.pointsize = options[:font_size]
      gc.stroke_width(0)
      gc.gravity = Magick::CenterGravity
      gc.font = "#{Rails.root}/public/fonts/arialbd.ttf"

      stats = gc.get_type_metrics(dummy, header)
      gc.text(0,50, header)
     # text.annotate(canvas, 0,0,0,0, header) {
    #      self.fill = 'white'
    #  }

      canvas = Magick::Image.new(stats.width, stats.height){
        self.background_color = 'transparent'
        self.format = 'PNG'
       }
       gc.annotate(canvas, stats.width, stats.height,0, -1 , header) {
           self.fill = 'black'
       }

       gc.annotate(canvas, stats.width, stats.height,0, 0 , header) {
           self.fill = 'white'
       }
      gc.draw(canvas)
      Rails.logger.info "writing #{file}"
      canvas.write(file)
    end

    path
  end

end