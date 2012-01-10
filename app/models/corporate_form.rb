# encoding: UTF-8
class CorporateForm < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  has_many :organisations
      
  def self.to_select_options
    find(:all, :order => "name ASC").map { |f| [f.name, f.id] }
  end                                      
    
end
