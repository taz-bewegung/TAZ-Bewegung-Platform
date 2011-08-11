module Search::EventSearch

  # Prepare the conditions for the search
  def prepare_conditions
    @conditions = ['events.state = "active"']
    date_filter_conditions
    place_conditions unless @place.blank?
    category_conditions unless @category_id.blank?
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

  # Build the date filter options.
  def date_filter_conditions  
    if @from_date.present?
      @conditions.add_condition ["events.ends_at > ?", Date.strptime(from_date, '%d.%m.%Y').beginning_of_day.to_s(:db)]
      @conditions.add_condition ["days_with_events.day > ?", Date.strptime(from_date, '%d.%m.%Y').beginning_of_day.to_s(:db)]
    else
      @conditions.add_condition ["events.starts_at > ?", Date.today.beginning_of_day]
    end
  end

  # Do the search
  def search(page = nil)
    prepare_conditions 
    query_options = { }
    query_options = { :page => page,  :per_page => 20 } if page.present?    
    Event.find_with_ferret(@search_query, query_options,
                                          :conditions => @conditions,
                                          :include => [:address, :social_category_memberships, :days_with_events])
    
  end
  
end