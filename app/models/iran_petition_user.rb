class IranPetitionUser < ActiveRecord::Base

  #establish_connection "iran_petition_#{Rails.env}"
  #set_table_name "users"

  scope :activated, { :conditions => "users.activated_at IS NOT NULL" }
  scope :latest,    { :order      => "users.activated_at DESC" }

  def to_s
    name
  end
end
