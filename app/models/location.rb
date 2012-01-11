# encoding: UTF-8
class Location < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid
  include AASM
  include Commentable
  
  # Plugins
  acts_as_paranoid
  
  ##
  # Associations
  belongs_to :owner, :polymorphic => true
  has_one :address, :as => :addressable
  has_one :image, :through => :image_attachment
  has_one :image_attachment, :as => :attachable, :dependent => :destroy
  has_many :location_category_memberships
  has_many :location_categories, :through => :location_category_memberships, :uniq => true
  has_many :activity_memberships, :as => :activity, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy  
  has_many :participants, :through => :activity_memberships, :class_name => "User", :source => :user  
  has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy  
  has_many :bookmark_users, :through => :bookmarks, :source => :user, :class_name => "User"  
  has_many :activities, :through => :location_memberships, :source => :activity,
                        :conditions => "location_memberships.member_type = 'Activity'"
  has_many :organisations, :through => :location_memberships, :source => :organisation,
                           :conditions => "location_memberships.member_type = 'Organisation'"
  #has_many :events, :through => :location_memberships, :source => :event,
  #                  :conditions => "location_memberships.member_type = 'Event'"
  #
  has_many :events  
  # Rails 2.3.2 new nested forms
  accepts_nested_attributes_for :address, :allow_destroy => true 
  accepts_nested_attributes_for :image_attachment
  
  ##
  # Validations
  validates_presence_of :name, :permalink, :description
  validates_uniqueness_of :permalink, :on => :create
  validates_format_of :email, :with => Authentication.email_regex, :allow_blank => true
  
  attr_accessor :temp_image

  
  ##
  # Scopes and finders
  
  #named_scope :active, { :conditions => { :state => 'active' } }      
  #named_scope :latest, { :order => "locations.created_at DESC" }  
  #named_scope :with_image, { :conditions => ["images.filename != ''"], :include => [:image] }
  #named_scope :ordered, lambda { |*order|
  #  { :order => order.flatten.first || 'locations.created_at DESC' }
  #}
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}  
  
  def self.find_latest_for_teaser_elements(offset)
    self.active.with_image.latest.find(:all, :limit => "#{offset},1")[0]
  end
  

#Acts as ferret
#  acts_as_ferret(
#  :fields => {
#    :name => { :boost => 5  },
#    :description => { :boost => 3 }
#    },
#    :additional_fields => [:index_address],
#    :store_class_name => true,
#    :remote => true
#    )
  
  def index_address
    self.address.to_short
  end


  ##
  # Acts as state machine
  
  aasm :column => :state do  
    # States
    state :suspended, :enter => :do_suspend
    state :active, :enter => :do_activate, :initial => true
  
    event(:activate) { transitions :from => [:suspended], :to => :active }
    event(:suspend) { transitions :from => [:active], :to => :suspended }
  end
  def do_suspend
  end
  
  def do_activate
  end  
  
  
  ##
  # Methods
  
  def title; name; end

  def to_param
    permalink
  end
  
  def to_index
    "#{self.name} #{self.address.street} #{self.address.zip_code} #{self.address.city}"
  end
  
  def bookmarkable_for?(user)
    return true if user.blank?
    return false if user.bookmarks.exists?({ :bookmarkable_type => "Location", :bookmarkable_id => self.id }) or self.owner == user
    true
  end 

  def bookmarked_by?(user)
    return false if user.blank?
    return true if user.bookmarks.exists?({ :bookmarkable_type => "Location", :bookmarkable_id => self.id })
    false    
  end  

  def visible_for?(user) 
    return false if user.blank? and not self.active?
    self.active? or user == self.owner or user.has_role?(:admin)
  end  
  
   
  
  def short_address
    self.name + "<br />" + self.address.to_html_long
  end
    
  def user_is_owner?(user)
    true
  end
  
  def self.get_paths
    path_ar = []
    
    self.find(:all).each do |model|
      path_ar<<{:url => "/locations/#{model.to_param}", :last_mod => model.updated_at.strftime('%Y-%m-%d')}
    end
    
    path_ar
  end
  
end
