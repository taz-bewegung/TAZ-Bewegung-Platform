module Search::LocationSearch
  
  # Prepare the conditions for the search
  def prepare_conditions
    @conditions = ['locations.state = "active"']
    place_conditions unless @place.blank?
    category_conditions unless @location_category_id.blank?    
    @conditions.add_condition ["1 = 0"] if not @date_filter.blank?
    @conditions
  end 
  
  # Build category_conditions
  def category_conditions
    @conditions.add_condition ["((location_category_memberships.location_category_id = ?))", @location_category_id]
  end  
  
  # Build conditions depending on the location.
  def place_conditions    
    @radius = @radius.blank? ? 10 : @radius
    origin = GeoKit::Geocoders::MultiGeocoder.geocode("#{@place}, Deutschland")
    distance_sql = Address.distance_sql(origin)
    @conditions.add_condition ["#{distance_sql} < ?", @radius]
  end

  # Do the search
  def search(page = nil)
    prepare_conditions
    query_options = { }
    query_options = { :page => page,  :per_page => 20 } if page.present?     
    Location.find_with_ferret @search_query, query_options,
                                             :conditions => @conditions,
                                             :include => [:address, :location_category_memberships]
  end
  
end