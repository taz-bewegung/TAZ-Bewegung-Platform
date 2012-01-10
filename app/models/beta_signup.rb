# encoding: UTF-8
class BetaSignup < ActiveRecord::Base
  # Modules
  include Bewegung::Uuid
  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :comment
  validates_format_of :email, :with => Authentication.email_regex
  
end
