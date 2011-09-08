module ExternalProfileMembershipsHelper
  
  def get_uri_host(url)
    begin
      uri = URI.parse(url).host
    rescue URI::InvalidURIError
      puts "Ein Fehler ist aufgetretten"
    end
    uri
  end
end
