module ValidationsHelper
  
  def span_class(object, method)
    object.errors.on(method).blank? ? 'green' : 'red'
  end
  
end
