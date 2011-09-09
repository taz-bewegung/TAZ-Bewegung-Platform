require File.dirname(__FILE__) + '/lib/helpedia_hidden_captcha'
 
ActiveRecord::Base.send(:include, Helpedia::HiddenCaptcha::Validations)
ActionView::Base.send(:include, Helpedia::HiddenCaptcha::Helper)
