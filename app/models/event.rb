# encoding: UTF-8
require 'icalendar'
class Event < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  # Plugins
  acts_as_paranoid
                                          
  PER_PAGE = { :overview_list => 20, :admin_list => 60 } unless defined?(PER_PAGE)
  
  ##
  # Virtual attributes
  
  attr_accessor :do_not_create_address, :temp_image
  attr_accessor :temp_image 
  attr_accessor :location_id_autocomplete
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time
  attr_accessor :api_time_handling          # Use standard time handling for api created events
  
  ##
  # Associations  
  
  belongs_to :originator, :polymorphic => true
  def owner; self.originator; end
  
  belongs_to :organisation
  belongs_to :event_category
  belongs_to :location  
  has_one :address, :as => :addressable
  has_one :image, :through => :image_attachment
  has_one :image_attachment, :as => :attachable#, :dependent => :destroy
#  has_many :activities
  has_many :days_with_events, :dependent => :destroy
  has_many :feed_events, :as => :trigger, :dependent => :destroy
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
  has_many :bookmark_users, :through => :bookmarks, :source => :user, :class_name => "User"
  has_many :social_category_memberships, :as => :member, :dependent => :destroy
  has_many :social_categories, 
    :through => :social_category_memberships,
    :uniq => true,    
    :conditions => "social_category_memberships.member_type = 'Event'"
  has_one :activity_event_membership, :dependent => :destroy
  has_one :activity, :through => :activity_event_membership
    
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :activity_event_membership
  accepts_nested_attributes_for :image_attachment
  
  
  def before_validation
    if self.website.present?
      self.website = ("http://" + self.website) if URI.parse(self.website).scheme.nil?
     end
  end
  
  
  ##
  # Validations  
  
  validates_presence_of :title, :description
  validates_format_of :website, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(([0-9]{2,6})?\/.*)?$/ix, :if => :website?, :allow_nil => true
  validates_uniqueness_of :permalink 
  validates_presence_of :starts_at, :if => Proc.new { |e| e.api_time_handling == true }
  validates_date :start_date, :if => Proc.new { |e| not e.api_time_handling == true }
  validates_time :start_time, :allow_blank => true
  validates_date :end_date, :allow_blank => true
  validates_time :end_time, :allow_blank => true
  
  ##
  # Scopes and finders
  
  #named_scope :active, { :conditions => { :state => 'active' } }
  #named_scope :upcoming, lambda { 
  #  { :conditions => ["events.starts_at > ?", Time.now], :order => "events.starts_at ASC"}
  #}
  #named_scope :running, { :conditions => ["events.ends_at > ?", Time.now], :order => "events.starts_at ASC"}
  #named_scope :finished, { :conditions => ["events.ends_at < ?", Time.now] }
  #named_scope :with_image, { :conditions => ["images.filename != ''"], :include => [:image] }  
  #named_scope :latest, { :order => "events.created_at DESC" }
  #named_scope :recent, { :order => "events.created_at ASC" }
  #
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}
  
  
  def self.find_latest_for_teaser_elements(offset)
    self.active.with_image.upcoming.latest.find(:all, :limit => "#{offset},1")[0]
  end


# Acts as ferret 

 #acts_as_ferret(
 #  :fields => {
 #    :title => { :boost => 5  },
 #    :description => { :boost => 3 }
 #  },
 #  :additional_fields => [:index_user, :index_organisation, :index_address],
 #  :store_class_name => true,
 #  :remote => true
 #)
  
  def index_user
    originator.full_name
  end
  
  def index_organisation
    organisation.name
  end
  
  def index_address
    self.location.blank? ? self.address.to_short : self.location.address.to_short
  end 
  
  
  
  def location_name
    unless self.location.blank?
      self.location.name
    else
      ""
    end
  end
  
  
  ##
  # Acts as state machine
  
  acts_as_state_machine :column => :state, :initial => :active
  
  # States
  state :suspended, :enter => :do_suspend
  state :active, :enter => :do_activate
  
  event(:activate) { transitions :from => :suspended, :to => :active }
  event(:suspend) { transitions :from => :active, :to => :suspended } 
  
  def do_suspend
  end
  
  def do_activate
  end  
   
  
  ##
  # Status methods
  
  def upcoming?
    self.starts_at > Time.now
  end
  
  def running?
    (self.starts_at < Time.now and self.ends_at > Time.now)
  end
  
  def finished?
    self.ends_at < Time.now
  end  
  
  def is_on_day?(day)
    self.starts_at < day.end_of_day and self.ends_at > day.beginning_of_day
  end


  ##
  # Methods
  
  def to_param
    permalink
  end 
  
  def start_time
    return @start_time unless @start_time.blank?
    return "" if self.new_record?
    date = I18n.l(starts_at.to_time, :format => :time)
    return date != "00:01" ? date : ""
  end
  
  def start_date
    return @start_date unless @start_date.blank?
    return self.new_record? ? "" : I18n.l(starts_at.to_date)
  end
  
  def end_date
    return @end_date unless @end_date.blank?
    return self.new_record? ? "" : I18n.l(ends_at.to_date)
  end  
  
  def end_time
    return @end_time unless @end_time.blank?
    return "" if self.new_record?
    date = I18n.l(ends_at.to_time, :format => :time)
    return date != "23:59" ? date : ""
  end  
   
  def set_unique_permalink
    temp_permalink = self.title.to_permalink
    count = self.class.count :conditions => ["permalink LIKE ? AND uuid != ?", "#{temp_permalink}%", self.id.to_s]
    if count == 0
      self.permalink = temp_permalink
    else
      self.permalink = "#{temp_permalink}-#{(count.to_i + 1).to_s}".to_permalink 
    end
  end
   
  def bookmarkable_for?(user)
    return true if user.blank?
    return false if user.bookmarks.exists?({ :bookmarkable_type => "Event", :bookmarkable_id => self.id }) or self.originator == user
    true
  end
  
  def bookmarked_by?(user)
    return false if user.blank?
    return true if user.bookmarks.exists?({ :bookmarkable_type => "Event", :bookmarkable_id => self.id })
    false    
  end 
  
  def visible_for?(user)
    return false if user.blank? and not self.active?
    self.active? or user == self.originator or user.has_role?(:admin)
  end
  
  #Group by 
  
  def month
    I18n.l self.starts_at.to_date.beginning_of_month, :format => "%B %Y"
  end
  
  def week
    I18n.l self.starts_at.to_date.beginning_of_week, :format => "%W %Y"
  end
  
  def day
    I18n.l self.starts_at.to_date.beginning_of_day, :format => "%d. %B %Y"
  end
  
  def self.get_paths
    path_ar = []
    
    self.find(:all).each do |model|
      path_ar << { :url => "/events/#{model.to_param}", :last_mod => model.updated_at.strftime('%Y-%m-%d') }
    end
    
    path_ar
  end
  
  ##
  # Representations
  
  def to_ical
    cal = Icalendar::Calendar.new
    cal.custom_property("METHOD","PUBLISH")
    #   loc_string = ""
    #   loc_string << self.location_name + ", " if !self.location_name.blank?
    #   loc_string << self.location_address

    # 	 event.url         "http://example.org/events/show/#{self.id.to_s}"

    ical_event = Icalendar::Event.new
    ical_event.summary = title
    ical_event.description = Sanitize.clean(self.description)
    ical_event.dtstart = DateTime.civil(self.starts_at.strftime("%Y").to_i, self.starts_at.strftime("%m").to_i, self.starts_at.strftime("%d").to_i,self.starts_at.strftime("%H").to_i, self.starts_at.strftime("%M").to_i)
    ical_event.dtend = DateTime.civil(self.ends_at.strftime("%Y").to_i, self.ends_at.strftime("%m").to_i, self.ends_at.strftime("%d").to_i,self.ends_at.strftime("%H").to_i, self.ends_at.strftime("%M").to_i)
    ical_event.dtstamp = DateTime.civil(self.created_at.strftime("%Y").to_i, self.created_at.strftime("%m").to_i, self.created_at.strftime("%d").to_i,self.created_at.strftime("%H").to_i, self.created_at.strftime("%M").to_i)
    ical_event.uid = "#{permalink}@taz.de"
    ical_event.klass = "PUBLIC"      
    ical_event.location = "#{address.street}, #{address.city}"
    ical_event.url = "http://bewegung.taz.de/termine/#{permalink}"
    cal.add_event(ical_event)
    cal.to_ical
  end
  
  def api_hash
    event_hash = ActiveSupport::OrderedHash.new
    event_hash[:uuid] = self.uuid
    event_hash[:title] = self.title
    event_hash[:url] = "http://bewegung.taz.de/termine/#{permalink}"
    event_hash[:starts_at] = self.starts_at
    event_hash[:ends_at] = self.ends_at
    event_hash[:description] = self.description
    event_hash[:image] = "http://bewegung.taz.de#{self.image.public_filename}" if self.image.present?
    event_hash[:organisation_id] = self.organisation_id if self.organisation_id.present?
    event_hash[:organisation_name] = self.organisation_name if self.organisation_id.present?
    event_hash[:social_categories] = Array.new
    social_categories.each do |cat|
    event_hash[:social_categories].push({ :social_categoy => cat.uuid })
  end    
    
    event_hash[:address] = ActiveSupport::OrderedHash.new
    event_hash[:address][:street] = self.address.street    
    event_hash[:address][:zip_code] = self.address.zip_code    
    event_hash[:address][:city] = self.address.city
    event_hash
  end    
  
end