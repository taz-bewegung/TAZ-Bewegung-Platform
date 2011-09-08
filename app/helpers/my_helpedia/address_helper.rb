module MyHelpedia::AddressHelper
  
  def wordify_geo_information(address)
    if address.has_geo_information?
      
      case address.geocode_precision
      when "address" then zoom = "14"
      when "country" then zoom = "4"
      when "zip" then zoom = "11"
      when "city" then zoom = "10"
      else zoom = "10"
      end
      
      image_tag('http://maps.google.com/staticmap?center=' + address.lat.to_s + ',' + address.lng.to_s + '&zoom=' + zoom + '&size=120x80&maptype=mobile' + 
                '&markers=' + address.lat.to_s + ',' + address.lng.to_s + ',red&key=' + GeoKit::Geocoders::google)
    else
      "Nicht sichbar (Addressinformationen können nicht zugewiesen werden)"
    end
  end
  
end
