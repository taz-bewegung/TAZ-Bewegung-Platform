# encoding: UTF-8
class Container < ActiveRecord::Base
  
  has_many :content_elements, :as => :container
  has_many :sub_containers, :as => :sub_container
#  belongs_to :parent_container, :class_name => "Container", :polymorphic => true
  
#  acts_as_list :scope => :parent_container
  
end
