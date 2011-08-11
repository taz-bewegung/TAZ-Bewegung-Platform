class Request
   include ActiveModel::Validations
   attr_accessor :name, :email, :message

   validates_presence_of :name
   validates_presence_of :email
   validates_presence_of :message
   
#   apply_simple_captcha :message => "Text und Bild stimmen nicht überein."
   
 end