class Session < ActiveRecord::BaseWithoutTable
   
   column :email, :string
   column :password, :string
   column :type, :text
   column :remember_me, :boolean
   column :forget_password_email, :string
   validates_presence_of :email, :password
      
end
