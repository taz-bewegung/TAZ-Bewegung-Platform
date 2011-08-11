module Search::OrganisationSearch
  
  # Prepare the conditions for the search
  def prepare_conditions
    @conditions = ['organisations.state = "active"']
    place_conditions unless @place.blank?
    category_conditions unless @category_id.blank?
    @conditions.add_condition ["1 = 0"] if not @date_filter.blank?
    @conditions
  end

  # Build category_conditions
  def category_conditions
    @conditions.add_condition ["((social_category_memberships.social_category_id = ?))", @category_id]
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
    Organisation.find_with_ferret @search_query, query_options,
                                         :conditions => @conditions,
                                         :include => [:address, :social_category_memberships]
  end
  
end