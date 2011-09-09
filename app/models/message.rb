# encoding: UTF-8
class Message < ActiveRecord::Base
  
  # Filters
  before_create :assign_conversation_id
  
  # Assiociations
  belongs_to :sender, :polymorphic => true 
  belongs_to :recipient, :polymorphic => true
  belongs_to :reply, :foreign_key => "reply_to_id", :class_name => "Message"
  
  ##
  # Validations
  validates_presence_of :subject, :body, :sender_id
  
  def validate
    errors.add(:recipient_id, :empty) if self.recipient_ids.blank? and self.recipient_id.blank?
  end

  ##
  # Scopes 
  #named_scope :unread, :conditions => 'read_at IS NULL'
  #named_scope :none_system_message, :conditions => ["system_message = ?", false] 
  #named_scope :for_conversation, lambda { |conversation_id|
  #  { :conditions => ['messages.conversation_id = ?', conversation_id] }
  #}
  #named_scope :grouped_by_conversation,
  #            :from => "(SELECT messages.* FROM messages ORDER BY sent_at DESC) AS messages",
  #            :group => 'messages.conversation_id', 
  #            :order => "messages.sent_at DESC"
  #

  attr_accessor :recipient_ids, :recipient_types, :send_to_users, :send_to_organisations, :do_not_send
  
  #
  def recipients_as_json
    if self.recipient_ids.blank? then return "" end
    users = self.recipient_types.classify.constantize.find :all, :conditions => { :uuid => [self.recipient_ids.join(",")] }
    users.map{ |user| { :value => user.id, :label => user.full_name} }.to_json
  end

  # Create multiple messages if required
  def handle_multi_recipients
    return if self.recipient_ids.blank?
    for user_id in self.recipient_ids
      m = Message.new(:subject => self.subject, :body => self.body)
      m.recipient_id, m.recipient_type = user_id, self.recipient_types
      m.sender = self.sender
      m.system_message = true if self.system_message
      m.save
    end
  end 
  
  def send_system_messages(sender)
    if @send_to_users
      User.all.each { |user| user.received_messages.create :body => self.body, :subject => self.body, :sender => sender, :system_message => true }
    end
    if @send_to_organisations
      Organisation.all.each { |orga| orga.received_messages.create :body => self.body, :subject => self.body, :sender => sender, :system_message => true }
    end    
  end 
  
  def deliver
    save unless @do_not_send == "1"
  end

  # Also delete messages in this conversation                                                    
  def delete_for(user)
    for message in Message.for_conversation(self.conversation_id)
      message.update_attributes( :sender_deleted_at => Time.now ) if message.sender == user
      message.update_attributes( :recipient_deleted_at => Time.now ) if message.recipient == user
    end
  end

  def is_reply_to(message)
    self.subject = message.subject
    self.reply = message    
  end
  
  def unread?
    !self.sent_at ? true : false
  end
  
  def mark_as_read
    self.update_attributes( :read_at => Time.now )
  end
  
  private 
    
    def assign_conversation_id
      self.conversation_id = UUID.timestamp_create.to_s if self.conversation_id.blank?
      self.sent_at = Time.now
    end
    
end
  