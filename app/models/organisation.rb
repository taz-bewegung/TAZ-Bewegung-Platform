# encoding: UTF-8
class Organisation < ActiveRecord::Base
  
  # Plugins
  acts_as_paranoid
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles
  
  ##
  # Virtual attributes
  attr_accessor :terms_of_use
  attr_accessor :receive_newsletter
  attr_accessor :temp_image
  attr_accessor :force_password_required 
  
  ##
  # Associations
  belongs_to :corporate_form
  has_one :address, :as => :addressable
  has_one :blog, :as => :bloggable, :dependent => :destroy
  has_one :image, :through => :image_attachment, :dependent => :destroy
  has_one :image_attachment, :as => :attachable, :dependent => :destroy
  
  has_many :system_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL AND system_message = ?", true], :as => :recipient, :dependent => :destroy
  has_many :received_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL AND system_message = ?", false], :as => :recipient, :dependent => :destroy
  has_many :all_received_messages, :class_name => 'Message', :conditions => ["messages.recipient_deleted_at is NULL"], :as => :recipient, :dependent => :destroy  
  has_many :sent_messages, :conditions => ["messages.sender_deleted_at is NULL AND system_message = ?", false], :class_name => 'Message', :as => :sender, :dependent => :destroy

  has_many :activity_memberships, :as => :activity, :dependent => :destroy
  has_many :participants, :through => :activity_memberships, :class_name => "User", :source => :user  
  
  has_many :comments, :as => :author, :dependent => :destroy
  has_many :images, :as => :owner, :order => "created_at DESC", :dependent => :destroy
  has_many :documents, :as => :owner, :order => "created_at DESC", :dependent => :destroy
  
  has_many :feed_events, :as => :trigger, :dependent => :destroy 
  has_many :feed_event_streams, :as => :streamable, :dependent => :destroy
  has_many :aggregated_feed_events, :through => :feed_event_streams, :source => :feed_event, :uniq => true
  
  has_many :activities, :as => :owner, :dependent => :destroy
  has_many :committed_events, :as => :originator, :class_name => "Event", :dependent => :destroy
  has_many :events, :as => :originator, :class_name => "Event", :dependent => :destroy    
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
  has_many :bookmark_users, :through => :bookmarks, :source => :user, :class_name => "User"
    
  has_many :locations, :as => :owner, :dependent => :destroy

  has_many :social_category_memberships, :as => :member
  has_many :social_categories, :source => :social_category, 
                               :through => :social_category_memberships, 
                               :conditions => ["social_category_memberships.member_type = 'Organisation'"],
                               :uniq => true                                    
                                  
  ##
  # Validations         
  validates_presence_of     :permalink
  validates_length_of       :permalink,    :within => 3..40
  validates_uniqueness_of   :permalink
  validates_format_of       :permalink,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  validates_presence_of     :name
  validates_presence_of     :corporate_form
  validates_length_of       :corporate_form_id, :minimum => 10
  validates_overall_uniqueness_of :contact_email, :if => :contact_email_changed?  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_format_of       :email,    :with => Authentication.email_regex
  validates_presence_of     :corporate_form
  validates_presence_of     :contact_name
  validates_presence_of     :contact_phone
  validates_presence_of     :description
  validates_presence_of     :contact_email
  validates_confirmation_of :contact_email
  validates_uniqueness_of   :contact_email  
  validates_format_of       :contact_email,    :with => Authentication.email_regex
  validates_presence_of     :main_category_id, :if => :main_category_id_changed?, :only => :create
  validates_acceptance_of   :terms_of_use,  :only => :create
#  validates_presence_of     :password, :if => :password_required?
#  validates_confirmation_of :password, :if => :password_required?    
  validates_presence_of     :password, :if =>  Proc.new { |organisation| organisation.password_required? || organisation.force_password_required? }
  validates_confirmation_of :password, :if => Proc.new { |organisation| organisation.password_required? || organisation.force_password_required? }  
  validates_acceptance_of   :agb, :only => :create 
  
  accepts_nested_attributes_for :image_attachment
  
  ##
  # Finders
  #named_scope :active, { :conditions => "organisations.state = 'active'" }  
  #named_scope :suspended, { :conditions => "organisations.state = 'suspended'" }
  #named_scope :recent, { :order => "created_at ASC" }
  #named_scope :with_image, { :conditions => ["images.filename != ''"], :include => [:image] }  
  #named_scope :ordered, lambda { |*order|
  #  { :order => order.flatten.first || 'organisations.created_at DESC' }
  #}  
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}    
  #named_scope :latest, { :order => "organisations.created_at DESC" }
  
  
  def self.find_latest_for_teaser_elements(offset)
    self.active.with_image.latest.find(:all, :limit => "#{offset},1")[0]
  end
  
  class << self
    def active
      where(:state => "active")
    end
  end
 # ##
 # # Acts as ferret
 # acts_as_ferret(
 #   :fields => {
 #     :name => { :boost => 5 },
 #     :description => { :boost => 3 }
 #   },
 #   :additional_fields => [:index_address],
 #   :store_class_name => true,
 #   :remote => true,
 #   :if => Proc.new { |organisation| organisation.active? }
 # ) 

  def index_address
    address.to_short
  end  
  
  ##
  # Interface methods
  def title; name; end
  def full_name; name; end 
  def notify_email; contact_email; end
  def notify_phone; contact_phone; end
  def notify_name; contact_name; end
  def friendable_for?(user); false; end                # Organisations don't have any friends
  def gender; 0; end 
  def owner; self; end
  def has_role?(*roles); false; end
  def roles; []; end
  def receive_message_notification; true; end
  
  ##
  # Methods
  
  def to_param
    permalink.downcase
  end
  
  def bookmarkable_for?(user)
    return true if user.blank?
    return false if user.bookmarks.exists?({ :bookmarkable_type => "Organisation", :bookmarkable_id => self.id }) or self == user
    true
  end

  def bookmarked_by?(user)
    return false if user.blank? or self == user
    return true if user.bookmarks.exists?({ :bookmarkable_type => "Organisation", :bookmarkable_id => self.id })
    false
  end
  
  def visible_for?(user) 
    return false if user.blank? and not self.active?
    self.active? or user == self or user.has_role?(:admin)
  end
  
  def already_logged_in?
    if self.first_logged_in_at.blank?
      self.update_attribute :first_logged_in_at, Time.now
      return false
    end
    true
  end
    
  def self.to_select_options
    self.active.ordered("name ASC").map { |f| [f.name, f.id] }
  end
  
  
  def wordify_receive_newsletter
    self.receive_newsletter? ? "Newsletter empfangen" : "nicht für Newsletter eingetragen"
  end
  

  def combined_social_categories
    categories = []
    categories << self.main_category unless self.main_category.blank?
    categories = categories + self.secondary_categories unless self.secondary_categories.blank?    
    categories
  end
  
  def receive_newsletter?
    subscriber = NewsletterSubscriber.find_by_email(self.helpedia_contact_email)
    not subscriber.blank?
  end 
  
  def receive_newsletter
    @receive_newsletter || receive_newsletter?
  end   
  
  def force_password_required?
    @force_password_required
  end  

  # Authenticate the organisation by permalink or email
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ["permalink = ? OR contact_email = ?", login, login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def permalink=(value)
    write_attribute :permalink, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  def contact_email=(value)
    write_attribute :contact_email, (value ? value.downcase : nil)
  end   
  def contact_email_confirmation=(value)
    @contact_email_confirmation = value ? value.downcase : nil
  end  
  
  def recently_reset_password?
    @reset_password
  end
  
  def recently_forgot_password?
    @forgotten_password
  end  
  
  # Keep track of login
  def log_login!
    update_attribute :logged_in_at, Time.now
  end
  
  def forgot_password!
    update_attribute :password_reset_code, Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
    
    # Also send email
    OrganisationMailer.deliver_send_password(self)
  end

  def changed_password!
    update_attributes(:password_reset_code => nil)
    # Also send email
    OrganisationMailer.deliver_password_changed(self)    
  end 

  
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
  end  
  
  def self.get_paths
    path_ar = []
    
    self.find(:all).each do |model|
      path_ar<<{:url => "/organisationen/#{model.to_param}", :last_mod => model.updated_at.strftime('%Y-%m-%d')}
    end
    
    path_ar
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end  
  
  def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
  end 
  
  
  def generate_api_key
    self.update_attribute :api_key, self.class.make_token
  end
  
  
  def api_hash
    hash = ActiveSupport::OrderedHash.new
    hash[:uuid] = self.uuid
    hash[:name] = self.name
    hash[:url] = "http://bewegung.taz.de/organisationen/#{permalink}"
    hash[:image] = "http://bewegung.taz.de#{self.image.public_filename}" if self.image.present?
    hash
  end 
    
  def to_json(options = {}) 
    api_hash.to_json
  end

end