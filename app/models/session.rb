class Session
   include ActiveModel::Validations
   #column :email, :string
   #column :password, :string
   #column :type, :text
   #column :remember_me, :boolean
   #column :forget_password_email, :string
   attr_accessor :email, :password, :type, :remember_me, :forget_password_email
   validates_presence_of :email, :password
      
end
