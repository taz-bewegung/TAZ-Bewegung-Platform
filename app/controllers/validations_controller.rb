# encoding: UTF-8
class ValidationsController < ApplicationController 
  
  protect_from_forgery :only => [:index]
  
  def permalink
    klass = params[:type].to_class    
    count = klass.find_by_permalink params[:value]
    instance_variable_set("@#{klass.to_s.underscore}", klass.new(:permalink => params[:value]))  
    instance_variable_get("@#{klass.to_s.underscore}").valid?
    @object = instance_variable_get("@#{klass.to_s.underscore}")
    render :layout => false
  end
    
end
