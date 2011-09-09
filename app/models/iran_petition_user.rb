# encoding: UTF-8
class IranPetitionUser < ActiveRecord::Base

  establish_connection "iran_petition_#{Rails.env}"
  set_table_name "users"

  #named_scope :activated, { :conditions => "users.activated_at IS NOT NULL" }
  #named_scope :latest,    { :order      => "users.activated_at DESC" }

  def to_s
    name
  end
end
