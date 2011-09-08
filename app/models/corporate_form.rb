class CorporateForm < ActiveRecord::Base
  
  has_many :organisations
      
  def self.to_select_options
    find(:all, :order => "name ASC").map { |f| [f.name, f.id] }
  end                                      
    
end
