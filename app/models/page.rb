# encoding: UTF-8
class Page < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  def to_param
    permalink.downcase
  end
  
end
