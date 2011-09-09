# encoding: UTF-8
class Page < ActiveRecord::Base
  
  def to_param
    permalink.downcase
  end
  
end
