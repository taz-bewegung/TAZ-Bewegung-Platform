# encoding: UTF-8
require 'digest/sha1'

class User < ActiveRecord::Base
  
  # Plugins
  acts_as_paranoid
   
  TITLES = [["Dr.", "1"],
            ["Prof.", "2"],
            ["Prof. Dr.", "3"]] unless defined?(TITLES)

  GENDERS = [["männlich", "1"],
             ["weiblich", "2"]] unless defined?(GENDERS)
            
  VISIBILITY = [["Profil nicht anzeigen", "1"],
                ["Profil angemeldeten Nutzern zeigen", "2"],
                ["Profil allen Nutzern zeigen", "3"]] unless defined?(VISIBILITY)                      
                
  MESSAGES_PER_PAGE = 20 unless defined?(MESSAGES_PER_PAGE)

  # Include modules
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  #include Authorization::StatefulRoles
    
  # Virtual attributes
  attr_accessor :do_not_create_address
  attr_accessor :forgotten_password  
  attr_accessor :force_password_required
  
  # For Migration
  attr_accessor :temp_image
    
  # Associations
  has_one :address, :as => :addressable
  has_one :image, :through => :image_attachment, :dependent => :destroy
  has_one :image_attachment, :as => :attachable, :dependent => :destroy
  has_many :activities, :as => :owner, :dependent => :destroy
  has_many :locations, :as => :owner, :dependent => :destroy  
  has_many :comments, :as => :author, :dependent => :destroy    
  has_many :images, :as => :owner, :order => "created_at DESC", :dependent => :destroy
  has_many :activity_memberships, :dependent => :destroy

#  has_many :event_activity_memberships, :class_name => "ActivityMembership", :conditions => ["activity_type = ?", "Event" ]
  has_many :organisation_activity_memberships, :class_name => "ActivityMembership", :conditions => ["activity_type = ?", "Organisation" ]
  has_many :activity_activity_memberships, :class_name => "ActivityMembership", :conditions => ["activity_type = ?", "Activity" ]
  has_many :location_activity_memberships, :class_name => "ActivityMembership", :conditions => ["activity_type = ?", "Location" ]
  has_many :participating_activities, :through => :activity_memberships, :class_name => "Activity", :source => :activity
  
  has_many :foreign_bookmarks, :as => :bookmarkable, :class_name => "Bookmark", :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy, :dependent => :destroy
  has_many :event_bookmarks, :through => :bookmarks, :source_type => "Event", :source => :bookmarkable, :uniq => true
  has_many :organisation_bookmarks, :through => :bookmarks, :source_type => "Organisation", :source => :bookmarkable, :uniq => true
  has_many :activity_bookmarks, :through => :bookmarks, :source_type => "Activity", :source => :bookmarkable, :uniq => true
  has_many :location_bookmarks, :through => :bookmarks, :source_type => "Location", :source => :bookmarkable, :uniq => true  
  has_many :friends, :class_name => "User", :through => :friendships, :conditions => "friendships.state = 'accepted'"

  # Destroy friendships in before_destroy_filter 
  has_many :friendships, :as => :user
  has_many :events, :as => :originator, :dependent => :destroy
  
  #Feed Events
  has_many :feed_events, :as => :operator, :dependent => :destroy
  has_many :feed_event_streams, :as => :streamable, :dependent => :destroy
  has_many :aggregated_feed_events, :through => :feed_event_streams, :source => :feed_event, :uniq => true
  

  has_many :system_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL AND system_message = ?", true], :as => :recipient, :dependent => :destroy
  has_many :received_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL AND system_message = ?", false], :as => :recipient, :dependent => :destroy
  has_many :all_received_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL"], :as => :recipient, :dependent => :destroy  
  has_many :sent_messages, :conditions => ["messages.sender_deleted_at is NULL AND system_message = ?", false], :class_name => 'Message', :as => :sender, :dependent => :destroy
  
  has_and_belongs_to_many :roles
  
  has_many :external_profile_memberships, :order => "created_at DESC"
  has_many :external_profiles, :through => :external_profile_memberships
  
  accepts_nested_attributes_for :image_attachment  
  
  ##
  # Validations
  validates_presence_of     :first_name
  validates_length_of       :first_name,     :within => 2..100 
  validates_presence_of     :last_name
  validates_length_of       :last_name,     :within => 2..100 
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_format_of       :email,    :with => Authentication.email_regex
  validates_presence_of     :password, :if =>  Proc.new { |user| user.password_required? || user.force_password_required? }
  validates_confirmation_of :password, :if => Proc.new { |user| user.password_required? || user.force_password_required? }
  validates_confirmation_of :email, :only => :create
  validates_overall_uniqueness_of :email, :if => :email_changed?
  validates_uniqueness_of   :email
  validates_uniqueness_of   :permalink, :case_sensitive => false
  validates_presence_of     :permalink
  validates_format_of       :permalink, :with => /^([^\d\W]|[-]|[\w])*$/
  validates_presence_of     :email_confirmation, :on => :create
  
  ##
  # Finders
  #named_scope :with_public_profile, { :conditions => "users.visibility = '3'" }
  #named_scope :active, { :conditions => "users.state = 'active'" }
  #named_scope :latest, { :order => "users.created_at DESC" }
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}
  #named_scope :beta, { :conditions => ["created_at BETWEEN ? AND ? AND state = 'pending'", Date.new(2009, 04, 17).beginning_of_day, Date.new(2009, 04, 19).end_of_day] }
  
  def self.active
    where("users.state", "active")
  end

##
# States

 acts_as_state_machine :initial => :pending
  state :passive
  state :pending
  state :active,  :enter => :do_activate
  state :suspended
  state :fairdo_migrator, :enter => :do_fairdo_migrator
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => [:pending, :fairdo_migrator], :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
  
  event :fairdo_migrator do
     transitions :from => [:passive, :pending], :to => :fairdo_migrator
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
  
  def do_fairdo_migrator
    #Send email
    UserMailer.deliver_fairdo_migration(self)
  end
  


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  
  def force_password_required?
    @force_password_required
  end 
  
  def already_logged_in?
    if self.first_logged_in_at.blank?
      self.update_attribute :first_logged_in_at, Time.now
      return false
    end
    true
  end
  
  def self.remind_beta_users
    User.beta.each do |user|
      UserMailer.deliver_beta_notification(user)
    end
  end
  
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => ['email = ?', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def self.admin_paginate(page = 1, order = 'id ASC', conditions = [])
    paginate :page => page,
             :per_page => 30,
             :conditions => conditions,
             :order => order
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  def email_confirmation=(value)
    @email_confirmation = value ? value.downcase : nil
  end
  
  # Interface methods for organisations.
  def notify_email; email; end
  def notify_phone; phone; end
  def notify_name; full_name; end  
  
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(*roles)
    @list ||= self.roles.collect(&:title)
    roles.each do |role|
      return true if @list.include?(role.to_s)
    end
    false
  end 
  
  def friendable_for?(user)
    return true if user.blank? 
    return false if user == self or user.is_a?(Organisation) or user.friendships.exists?({ :user_type => "User", :friend_id => self.id })
    true
  end  
  
  def visible_for?(user)
    if self.active?
      return true if user.blank? and self.visible_for_public?
      return true if user and self.visible_for_logged_in?
    else
      return true if user == self or user.has_role?(:admin)
    end
    false
  end 
  
  def visible?
    not visibility.blank? and not visibility == "1"
  end
  
  def visible_for_logged_in?
    visibility == "2" or visibility == "3"
  end
  
  def visible_for_public?
    visibility == "3"
  end 

  def wordify_title
    word = nil
    TITLES.each do |t| 
      if t[1] == self.title then word = t[0] end
    end
    word
  end
  
  def wordify_visibility
    word = nil
    VISIBILITY.each do |t| 
      if t[1] == self.visibility then word = t[0] end
    end
    word
  end
  
  def wordify_gender
    word = nil
    GENDERS.each do |t| 
      if t[1] == self.gender then word = t[0] end
    end
    word
  end
  
  def wordify_receive_newsletter
    self.receive_newsletter? ? "Newsletter empfangen" : "nicht für Newsletter eingetragen"
  end
  
  def wordify_receive_message_notification
    self.receive_message_notification ? "Vollständige Benachrichtung über neue Nachrichten via E-Mail" : "Info-Benachrichtigungsemail für neue Nachrichten"
  end
  
  def full_name
    permalink.downcase
  end
  alias_method :name, :full_name
    
  def name_with_max_length(length = 30, options = {})
    options.reverse_merge!(:omission => "...")
    l = length - options[:omission].mb_chars.length
    chars = permalink.mb_chars
    (chars.length > length ? chars[0...l] + options[:omission] : permalink).to_s
  end
  
  def full_name_cropped(length) 
    name = [first_name_cropped(length), last_name_cropped(length)]
    name.insert(0, wordify_title) unless self.title.blank? 
    name.join(" ")    
  end
  
  def first_name_cropped(length) 
    first_name.length > length ? "#{first_name.first}." : first_name
  end
  
  def last_name_cropped(length)
    last_name.length > length ? "#{last_name.first}." : last_name
  end
  
  def contact_name
    fullname
  end  
  
  def public_address
    "#{address.zip_code} #{address.city}"
  end
    
  def to_param
    permalink.downcase
  end 
  
  def generate_unique_permalink
    unless first_name.blank? and last_name.blank?
      temp = "#{first_name} #{last_name}".to_permalink
    else
      temp = email.split("@")[0].to_permalink               # If there is no name, use the email address
    end    
    
    count = User.count :conditions => ["permalink LIKE ?", "#{temp}%"]
    if count == 0
      self.permalink = temp.to_permalink 
    else
      self.permalink = "#{temp}-#{(count.to_i + 1).to_s}".to_permalink 
    end    
  end
    
  def bookmarked_by(user)
    bookmark = self.foreign_bookmarks.find(:first, :conditions => ["user_id = ?", user.id])
  end      
  
  def receive_newsletter?
    not NewsletterSubscriber.find_by_email(self.email).blank?
  end
  
  def receive_newsletter
    @receive_newsletter || receive_newsletter?
  end
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end 
  
  def recently_forgot_password?
    @forgotten_password
  end   

  
  def trashed_messages(page = 1)
     conditions = [%((sender_id = :user AND sender_deleted_at > :t) OR
                     (recipient_id = :user AND recipient_deleted_at > :t)),
                   { :user => id, :t => 1.month.ago }]
     order = 'created_at DESC'
     trashed = Message.paginate(:all, :conditions => conditions,
                                      :order => order,
                                      :page => page,
                                      :per_page => MESSAGES_PER_PAGE)
   end  
  
  
  # Keep track of login
  def log_login!
    update_attribute :logged_in_at, Time.now
  end
  
  def forgot_password!
    update_attribute :password_reset_code, Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
    
    # Also send email
    UserMailer.deliver_send_password(self)
  end

  def changed_password!
    update_attributes(:password_reset_code => nil)
    # Also send email
    UserMailer.deliver_password_changed(self)    
  end 
  
  def self.get_paths
    path_ar = []
    
    self.with_public_profile.each do |model|
      path_ar<<{:url => "/users/#{model.to_param}", :last_mod => model.updated_at.strftime('%Y-%m-%d')}
    end
    
    path_ar
  end

end
