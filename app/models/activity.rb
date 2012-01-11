# encoding: UTF-8
class Activity < ActiveRecord::Base 
  
  include Commentable

  # Plugins
  acts_as_paranoid

  ##
  # Virtual attributes
  attr_accessor :do_not_create_address, :temp_image
  
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time 
       
  ##
  # Associations
  belongs_to :owner, :polymorphic => true
  belongs_to :location
  
  has_one :blog, :as => :bloggable, :dependent => :destroy  
  has_one :address, :as => :addressable
  has_one :image, :through => :image_attachment
  has_one :image_attachment, :as => :attachable#, :dependent => :destroy
  has_many :feed_events, :as => :trigger, :dependent => :destroy  
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :participants, :through => :activity_memberships, :class_name => "User", :source => :user
  has_many :activity_memberships, :as => :activity, :dependent => :destroy
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
  has_many :bookmark_users, :through => :bookmarks, :source => :user, :class_name => "User"
  has_many :social_category_memberships, :as => :member, :dependent => :destroy, :uniq => true
  has_many :social_categories, 
    :through => :social_category_memberships,
    :conditions => "social_category_memberships.member_type = 'Activity'",
    :uniq => true
    
  has_many :activity_event_memberships, :dependent => :destroy
  has_many :events, :through => :activity_event_memberships

  # Validations
  validates_presence_of :permalink, :title, :description, :goal, :participation
  validates_length_of :participation, :maximum => 140
  validates_length_of :goal, :maximum => 140  
  validates_date :end_date
  validate :check_code
  
  # Modules
  include Bewegung::Uuid

  accepts_nested_attributes_for :image_attachment

  ##
  # Scopes and finders

  #named_scope :running, { :conditions => ["activities.ends_at > ?", Time.now] }
  #named_scope :active, { :conditions => "activities.state = 'active'" }
  #named_scope :recent, { :order => "activities.starts_at ASC" }
  #named_scope :latest, { :order => "activities.created_at DESC" }  
  #named_scope :finished, { :conditions => ["activities.continuous = ? AND activities.ends_at < ?", false, Time.now] }
  #named_scope :with_image, { :conditions => ["images.filename != ''"], :include => [:image] }
  #named_scope :ordered, lambda { |*order|
  #  { :order => order.flatten.first || 'activities.created_at DESC' }
  #}
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}

  def self.find_latest_for_teaser_elements(offset)
    self.active.with_image.running.latest.find(:all, :limit => "#{offset},1")[0]
  end


#  Acts as ferret
#acts_as_ferret(
#  :fields => {
#    :title => { :boost => 5 },
#    :description => { :boost => 3 },
#    :index_user => { :boost => 2 }, 
#    :index_address => { :boost => 2 }
#  },
#  :store_class_name => true,
#  :remote => true,
#  :if => Proc.new { |activity| activity.running? }
#)
  
  def wikileaked?
    true if self.permalink == '4wikileaks'
  end

  def iranized?
    true if self.permalink == 'iran'
  end
  
  def petition_users_count
    
    if(iranized?)
      IranPetitionUser.activated.count
    elsif wikileaked?
      PetitionUser.activated.count
    else
      0
    end
    
  end

  def index_user
    owner.full_name
  end

  def index_address
    self.location.blank? ? self.address.to_index : self.location.to_index
  end 

  ##
  # Acts as state machine
  include AASM
  aasm :column => :state do
    # States
    state :suspended, :enter => :do_suspend
    state :active, :enter => :do_activate, :initial => true
    # Events
    event(:activate) { transitions :from => [:suspended], :to => :active }
    event(:suspend) { transitions :from => [:active], :to => :suspended }
  end

  def do_suspend
  end
  
  def do_activate
  end
  
  
  ##
  # Methods
  
  def location_name
    unless self.location.blank?
      self.location.name
    else
      ""
    end
  end
  
  def real_address
    self.location || self.address
  end
 
  
  def fininshing_in?(time)
    self.ends_at < time
  end       
  
  def running?
    (self.starts_at < Time.now and self.ends_at > Time.now)
  rescue
    false
  end
  alias_method :is_running?, :running?
  
  def is_on_day?(day)
    self.ends_at = self.starts_at if self.ends_at.blank?
    (self.starts_at.to_date..self.ends_at.to_date).to_a.include?(day)
  end  
    
  def short_address
    self.address.street + "<br />" + self.address.zip_code + " " + self.address.city
  end
  
  def generate_unique_permalink 
    temp = self.title.to_permalink
    count = User.count :conditions => ["permalink = ?", temp]
    if count == 0
      self.permalink = temp.to_permalink 
    else
      self.permalink = "#{temp}-#{(count.to_i + 1).to_s}".to_permalink 
    end    
  end

  def bookmarkable_for?(user)
    return true if user.blank?
    return false if user.bookmarks.exists?({ :bookmarkable_type => "Activity", :bookmarkable_id => self.id }) or self.owner == user
    true
  end
  
  def bookmarked_by?(user)
    return false if user.blank?
    return true if user.bookmarks.exists?({ :bookmarkable_type => "Activity", :bookmarkable_id => self.id })
    false    
  end
  
  def visible_for?(user) 
    return false if user.blank? and not self.active?
    self.active? or user == self.owner or user.has_role?(:admin)
  end  
  
  #Group by 
  
  def month
    I18n.l self.starts_at.to_date.beginning_of_month, :format => "%B %Y"
  end
  
  def week
    I18n.l self.starts_at.to_date.beginning_of_week, :format => "%W %Y"
  end
  
  def day
    I18n.l self.starts_at.to_date.beginning_of_day, :format => "%d. %B"
  end
  
  
  def start_time
    return @start_time unless @start_time.blank?
    return "" if self.new_record? or starts_at.blank?
    date = I18n.l(starts_at.to_time, :format => :time)
    return date != "00:00" ? date : ""
  end
  
  def start_date
    return @start_date unless @start_date.blank?
    return (new_record? or starts_at.blank?) ? "" : I18n.l(starts_at.to_date)
  end
  
  def end_date
    return @end_date unless @end_date.blank?
    return (new_record? or ends_at.blank?) ? "" : I18n.l(ends_at.to_date)
  end  
  
  def end_time
    return @end_time unless @end_time.blank?
    return "" if self.new_record? or ends_at.blank?
    date = I18n.l(ends_at.to_time, :format => :time)
    return date != "00:00" ? date : ""
  end  
  

  ##
  # Representations
  
  def to_param
    permalink.downcase
  end
  
  def to_ical
    cal = Icalendar::Calendar.new
    cal.custom_property("METHOD","PUBLISH")
 #   loc_string = ""
 #   loc_string << self.location_name + ", " if !self.location_name.blank?
 #   loc_string << self.location_address
    ical_event = Icalendar::Event.new
    ical_event.summary = title
    ical_event.description = Sanitize.clean(self.description)
    ical_event.dtstart = DateTime.civil(self.starts_at.strftime("%Y").to_i, self.starts_at.strftime("%m").to_i, self.starts_at.strftime("%d").to_i,self.starts_at.strftime("%H").to_i, self.starts_at.strftime("%M").to_i)
    ical_event.dtend = DateTime.civil(self.ends_at.strftime("%Y").to_i, self.ends_at.strftime("%m").to_i, self.ends_at.strftime("%d").to_i,self.ends_at.strftime("%H").to_i, self.ends_at.strftime("%M").to_i)
    ical_event.dtstamp = DateTime.civil(self.created_at.strftime("%Y").to_i, self.created_at.strftime("%m").to_i, self.created_at.strftime("%d").to_i,self.created_at.strftime("%H").to_i, self.created_at.strftime("%M").to_i)
    ical_event.uid = "#{permalink}@taz.de"
    ical_event.klass = "PUBLIC"      
    ical_event.location = "#{address.street}, #{address.city}"
    ical_event.url = "http://bewegung.taz.de/aktionen/#{permalink}"
    cal.add_event(ical_event)
    cal.to_ical
  end  
  
  
  
  # for XML Sitemap
  def self.get_paths
    path_ar = []
    
    self.find(:all).each do |model|
      path_ar<<{:url => "/activities/#{model.to_param}", :last_mod => model.updated_at.strftime('%Y-%m-%d')}
    end
    
    path_ar
  end
  
  protected
  
  def check_code
    doc = Nokogiri::HTML(self.code).search("iframe")
    
    if doc.length == 1
      check_iframe(doc.first)
    end
    
    if doc.length > 1
      errors.add(:code, "Bitte maximal ein Iframe einbinden")
    end
    
  end

  def check_iframe(doc)
    host = URI.parse(doc.attributes["src"]).host
    errors.add(:code, "Diese Domain wird nicht unterstützt") unless BlogContentVideoWithCode::ALLOWED_SITES.include?(host)
  end

  
    
end
