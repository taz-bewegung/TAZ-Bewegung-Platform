cache("orte/index/rss-#{@cache_key}", :expires_in => 30.minutes, :format => :xml) do
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
  xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
    xml.channel do
      xml.title       "Neue Orte auf bewegung.taz.de"
      xml.link        url_for :only_path => false, :controller => 'locations'
      xml.pubDate     CGI.rfc1123_date @@locations.last.updated_at if @posts.present?
      #xml.description "Von der kleinen kreativen Aktion, bis zur großen bundesweiten Kampagne. Hier können sich alle aktiv einbringen, sich austauschen und gemeinsam Projekte starten. Bewegte Menschen, Initiativen und Organisationen können sich vernetzen und dann zusammen ihre Ideen für eine bessere Welt in die Tat umsetzen."
      xml.language "de-de"
      @locations.each do |post|
        xml.item do
          xml.title       post.title
          xml.link        url_for :only_path => false, :controller => 'locations', :action => 'show', :id => post.permalink
          # xml.description image_for(post, :large, :style => "float:left").to_s + post.address.city
          xml.description post.address.city unless post.address.nil?
          xml.pubDate     CGI.rfc1123_date post.updated_at
          xml.guid        url_for :only_path => false, :controller => 'locations', :action => 'show', :id => post.permalink
          xml.author      post.owner.full_name
        end
      end
    end
  end
end

