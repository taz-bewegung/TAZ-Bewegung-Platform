class FlyerOrder < ActiveRecord::BaseWithoutTable
  
  column :flyer_amount, :integer
  column :poster_amount, :integer  
  
  column :name, :string
  column :email, :string
  column :street, :string
  column :zip, :string
  column :city, :string  
  
  validates_numericality_of :flyer_amount, :allow_blank => true
  validates_numericality_of :poster_amount, :allow_blank => true  
  validates_presence_of :street
  validates_presence_of :city
  validates_presence_of :name
  validates_presence_of :zip  
  validates_presence_of :email
  validates_length_of   :email,    :within => 6..100 #r@a.wk
  validates_format_of   :email,    :with => Authentication.email_regex
  
  def to_param
    "1"
  end  
  
end
