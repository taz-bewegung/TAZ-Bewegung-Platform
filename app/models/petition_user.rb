class PetitionUser < ActiveRecord::Base

  establish_connection "petition_#{RAILS_ENV}"
  set_table_name "users"

  named_scope :activated, { :conditions => "users.activated_at IS NOT NULL" }
  named_scope :latest,    { :order      => "users.activated_at DESC" }

  def to_s
    name
  end
end
