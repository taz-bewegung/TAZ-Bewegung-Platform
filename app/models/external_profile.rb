# encoding: UTF-8
class ExternalProfile < ActiveRecord::Base
  
  has_many :external_profile_mappings
  has_many :users, :through => :external_profile_mappings
  
  def self.to_select_options
    find(:all).map { |f| [f.title, f.id] }
  end

  
end
