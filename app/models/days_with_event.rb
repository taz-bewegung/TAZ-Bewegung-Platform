# encoding: UTF-8
class DaysWithEvent < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  belongs_to :event
  
  #named_scope :running, { :conditions => ["days_with_events.day >= ? AND events.starts_at <= ? AND events.ends_at >= ?", Time.now.beginning_of_day-2.hours, Time.now.end_of_day, Time.now.beginning_of_day],
  #                        :include => :event, :group => "events.uuid" }
  #named_scope :recent, { :order => "days_with_events.day ASC" }
  #named_scope :active, { :include => :event, :conditions => { :events => { :state => "active" }}}
  #named_scope :limit, lambda { |l|
  #  { :limit => l }
  #}  
  #named_scope :running, lambda { |time|
  #  if time.nil? or time.is_a?(Time) == false then
  #    time = Time.now
  #  end 
  #  { :conditions => ["days_with_events.day >= ? AND events.starts_at <= ? AND events.ends_at >= ?", time.beginning_of_day-2.hours, time.end_of_day, time.beginning_of_day],
  #                    :include => :event, :group => "events.uuid"}
  #  }
end