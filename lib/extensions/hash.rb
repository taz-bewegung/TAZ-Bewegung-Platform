class Hash
 
  def has_keys?(*keys)
    keys.each do |key|
      return  true if has_key?(key)
    end
    return false
  end

  def to_json(options = {}) #:nodoc:
    options.reverse_merge! :spacer_size => 1
    hash_keys = self.keys
    
    if except = options[:except]
      hash_keys = hash_keys - Array.wrap(except)
    elsif only = options[:only]
      hash_keys = hash_keys & Array.wrap(only)
    end
    
    spacer = ' '
    result = "\r\n #{spacer * options[:spacer_size]}{"
    result << hash_keys.map do |key|
 "#{ActiveSupport::JSON.encode(key.to_s)}: #{ActiveSupport::JSON.encode(self[key],
 options.merge(:spacer_size => options[:spacer_size]+7))}"
    end * " ,\r\n #{spacer * (options[:spacer_size]+1)}"
    result << '}'
  end
end