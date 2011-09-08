class Request < ActiveRecord::BaseWithoutTable
   
   column :name, :string
   column :email, :string
   column :message, :text

   validates_presence_of :name
   validates_presence_of :email
   validates_presence_of :message
   
#   apply_simple_captcha :message => "Text und Bild stimmen nicht überein."
   
 end