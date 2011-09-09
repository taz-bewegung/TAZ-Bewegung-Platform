# Load configatron, then name it application
configatron.configure_from_yaml("config/application.yml", :hash => Rails.env)
module Kernel
  alias_method :application, :configatron
end