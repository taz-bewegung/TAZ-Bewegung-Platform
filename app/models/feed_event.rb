# encoding: UTF-8
class FeedEvent < ActiveRecord::Base
  
  acts_as_mappable  
  
  serialize :changes
  has_many :feed_event_streams, :dependent => :destroy
  
  belongs_to :operator, :polymorphic => true      # Involved user / organisation
  belongs_to :trigger, :polymorphic => true       # Which object called the action  
  belongs_to :concerned, :polymorphic => true     # Which main object is concered (User, Event, Activity, Location, Organisation)
  
  #named_scope :latest, { :order => "feed_events.created_at DESC" }  
  #named_scope :public_visible, { :conditions => ["feed_events.is_public = ?", true] }
  #
  #named_scope :limit, lambda { |*num|
  #  { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
  #}
  #
  #named_scope :around, lambda { |address|
  #  { :conditions => ["#{FeedEvent.distance_sql(address)} < ?", 50] }
  #}
  #
  #named_scope :by_type, lambda { |parameters|
  #    { :conditions => { :type => parameters.map{ |t| t[0].camelize } } } 
  #  }
  class << self
    
    def latest
      order("feed_events.created_at DESC")
    end

    def public_visible
      where("feed_events.is_public", true)
    end

    def limit(num)
      limit(num.flatten.first || (defined?(per_page) ? per_page : 10))
    end
  end
  
end

class PublicFeedEvent < FeedEvent
  before_create :make_public
  
  EXPIRE_DURATION = 1.hour unless defined? EXPIRE_DURATION
  
  def make_public
    self.is_public = true
  end
end

#Public Events (visible on homepage and user page)
class ActivityCreateEvent < PublicFeedEvent; end            # An activity is created
class LocationCreateEvent < PublicFeedEvent; end            # An activity is created
class EventCreateEvent < PublicFeedEvent; end               # An event is created
class UserRegisterEvent < PublicFeedEvent; end              # User registered
class OrganisationActiveEvent < PublicFeedEvent; end        # Organisation is activated
class ActivityMembershipCreateEvent < PublicFeedEvent; end  # A new activity_membership is created
class BlogPostPublishEvent < PublicFeedEvent; end           # A blogmessage is published
class CommentEvent < PublicFeedEvent; end                   # A blog comment is published


#Private Events (visible just for admins)
#class DocumentUploadEvent < FeedEvent; end                 # User/Organisation uploads document
class OrganisationRegisterEvent < FeedEvent; end            # Organisation registered
class UserChangeEvent < FeedEvent; end                      # User changed his profile
class OrganisationChangeEvent < FeedEvent; end              # Organisation changed its profile
class LoginEvent < FeedEvent; end                           # User/Organisation logged in
class ImageUploadEvent < FeedEvent; end                     # User/Organisation uploads image
class BlogPostCreateEvent < FeedEvent; end                  # A blogpost is created
class NewFriendshipEvent < FeedEvent; end                   # Users become friends