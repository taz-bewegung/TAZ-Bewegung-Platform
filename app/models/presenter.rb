# from Jay Fields http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
# adapted by Mike Subelsky (http://subelsky.com/) to include ActiveRecord error combination

require "forwardable"

class Presenter
  extend Forwardable
  
  def initialize(params)
    params.each_pair do |attribute, value| 
      self.send :"#{attribute}=", value
    end unless params.nil?
  end
  
  # Combines errors from individual ActiveRecord objects, so we present something nice to the user
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end

  # needed by error_messages_for

  def self.human_attribute_name(attrib)
    attrib.humanize
  end

  def detect_and_combine_errors(*objects)
    objects.each do |obj|
      next if obj.nil?
      obj.valid?
      obj.errors.each { |k,m| errors.add(k,m) }
    end
  end
  
  def combine_errors(*objects)
    objects.each do |obj|
      obj.errors.each { |k,m| errors.add(k,m) }
    end
  end

end