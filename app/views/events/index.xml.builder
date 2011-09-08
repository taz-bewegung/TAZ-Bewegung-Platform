xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title       "Termine auf bewegung.taz.de"
    xml.link        url_for :only_path => false, :controller => 'events'
    xml.pubDate     CGI.rfc1123_date @events.first.created_at
    xml.language "de-de"
    @events.each do |event|
      xml.item do
        xml.title       event.title
        xml.link        event_url(event)
        xml.description time_span_for(event) + "<br />" + image_tag(image_url_for(event, :large)) + event.description
        xml.pubDate     CGI.rfc1123_date event.starts_at
        xml.guid        event_url(event)
        xml.author      event.owner.full_name
      end
    end
  end
end