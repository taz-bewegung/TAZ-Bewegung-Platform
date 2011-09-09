# encoding: UTF-8
class PetitionUser < ActiveRecord::Base

  establish_connection "petition_#{Rails.env}"
  set_table_name "users"

  #named_scope :activated, { :conditions => "users.activated_at IS NOT NULL" }
  #named_scope :latest,    { :order      => "users.activated_at DESC" }

  def to_s
    name
  end
end
