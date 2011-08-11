class Admin::Text
  
  attr_accessor :data, :file
  
  def initialize(file = nil)
    unless file.nil?
      self.data = load_from(file).sort 
      self.file = file
    end
  end
  
  def load_from(file)
    YAML::load(File.open("#{Rails.root}/app/locales/de/#{file}.yml"))
  end
  
  def save_to(file)
    File.open("#{Rails.root}/app/locales/de/#{file}.yml", "w") do |out|
      YAML.dump(self.data, out)
    end
    I18n.reload!
  end
   
end
