# encoding: UTF-8
class Address < ActiveRecord::Base
  
  # Plugins
  acts_as_mappable
  # acts_as_paranoid # TODO Figure out why this is not working (frozen hash error)
  
  attr_accessor :do_not_ask_google, :force_reload
    
  # Associations
  belongs_to :addressable, :polymorphic => true
  
  # Filters
  before_save :set_default_country
  before_save :set_geocode
  after_save :update_feed_events
  
  # Validations
  validates_presence_of :street, :if => Proc.new { |a| not a.nationwide? }
  validates_presence_of :zip_code, :if => Proc.new { |a| not a.nationwide? }
  validates_presence_of :city, :if => Proc.new { |a| not a.nationwide? }
  
  ##
  # Methods
  
  def to_geo_address(options = {})
    address = []
    address << street             if not street.blank? and not options[:reduced] == true
    address << zip_code           unless zip_code.blank?
    address << city               unless city.blank? 
    address << country_code       unless country_code.blank?
    address.join(",  ")
  end 
  
  def to_index
    address = []
    address << name               if name.present?
    address << street             if street.present?
    address << zip_code           unless zip_code.blank?
    address << city               unless city.blank? 
    address << state              unless state.blank?
    address << country_code       unless country_code.blank?
    address.join(" ")
  end
  
  def has_geo_information?
    not self.lat.blank? and not self.lng.blank?
  end
    
  def long
    "#{self.street}, #{self.zip_code}, #{self.city}"
  end
  
  def to_long
    address = []
    address << name               unless name.blank?
    address << street             unless street.blank?    
    address << zip_code           unless zip_code.blank?
    address << city               unless city.blank?
    address.join(" ")
  end  
  
  def to_html_long(delimiter = "<br />")
    address = []
    address << name               unless name.blank?
    address << street             unless street.blank?
    address << zip_code           unless zip_code.blank?
    address << city               unless city.blank?
    address.join(delimiter)
  end
  
  def to_short(delimiter = ", ")
    return Address.human_attribute_name("nationwide") if self.nationwide
    address = []
    address << name unless name.blank?
    address << zip_code unless zip_code.blank?
    address << city     unless city.blank?
    address.join(delimiter)
  end
      
  # Fetches the geoinformation from google, before an address is saved. 
  def set_geocode
    if do_not_ask_google then return end
      
    if city_changed? or street_changed? or zip_code_changed? or @force_reload
      address = self.addressable.is_a?(User) ? self.to_geo_address(:reduced => true) : self.to_geo_address
      geocode = GeoKit::Geocoders::MultiGeocoder.geocode(address)
      if geocode.success
        self.lat = geocode.lat
        self.lng = geocode.lng
        self.geocode_precision = geocode.precision
        self.state = geocode.state
      else
        self.lat = nil
        self.lng = nil
        self.geocode_precision = nil
      end
    end
  end
    
  # If no country is set, we use the default of the application.
  def set_default_country
    self.country_code = "Deutschland" if self.country_code.nil?
  end 
  
  # Triggered after an address is updated.
  def update_feed_events
    FeedEvent.find_all_by_concerned_id(self.addressable.try(:uuid)).each do |feed_event|
      feed_event.update_attributes(:lat => self.lat, :lng => self.lng)
    end
  end
  
end
