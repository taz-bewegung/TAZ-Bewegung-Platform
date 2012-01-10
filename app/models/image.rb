# encoding: UTF-8
class Image < ActiveRecord::Base

  # Modules
  include Bewegung::Uuid

  STANDARD_THUMBNAILS = {
    :mini => '32x24',
    :small => '90x69',
    :medium => '130x100', 
    :teaser => '170x130',
    :large => '236x182'
  } unless defined?(STANDARD_THUMBNAILS)
  
  # Plugins
  acts_as_paranoid
  
  belongs_to :owner, :polymorphic => true
  has_many :image_attachments, :as => :attachable, :dependent => :destroy
  has_many :feed_events, :as => :trigger, :dependent => :destroy
  
  attr_accessor :imageable_id, :imageable_type
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h  
  
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :path_prefix => 'public/uploads/', 
                  :max_size => 4.megabytes,
                  :thumbnails => STANDARD_THUMBNAILS,
                  :processor => :Rmagick,
                  :uuid_primary_key => true


  # Do not destroy original file (usually called from after_destroy)
  def destroy_file
    if File.exist?(full_filename)
      FileUtils.rm full_filename unless self.parent_id.blank?
    end
  end
  
  def destroy_thumbnails
    self.thumbnails.each { |thumbnail| thumbnail.destroy! } if thumbnailable?
  end

  def resize_all
    puts "Resizing #{self.filename}" 
    temp_file = self.create_temp_file
    self.attachment_options[:thumbnails].each { |suffix, size|
      self.create_or_update_thumbnail(temp_file, suffix, *size)
    }    
  end
  
  def find_or_create_thumbnail(size)
    unless self.thumbnails.detect { |t| t.thumbnail == size.to_s }
      temp_file = self.create_temp_file
      self.create_or_update_thumbnail(temp_file, size, *size.to_s)
      self.reload
    end
  end
  
  def validate
     errors.add_to_base("Bitte ein Bild auswählen") unless self.filename

     unless self.filename == nil

       # Images should only be GIF, JPEG, or PNG
       [:content_type].each do |attr_name|
         enum = attachment_options[attr_name]
         unless enum.nil? || enum.include?(send(attr_name))
           errors.add_to_base("Das Bild muss folgendes Format besitzen: GIF, JPEG oder PNG!")
         end
       end

       # Images should be less than 3 MB
       [:size].each do |attr_name|
         enum = attachment_options[attr_name]
         unless enum.nil? || enum.include?(send(attr_name))
           errors.add_to_base("Das Bild muss kleiner als 3 MB sein!")
         end
       end

     end
   end
     
  def size_for_thumbnail(size)
    thumbnails.each do |thumb|
      return thumb if thumb.thumbnail == size.to_s
    end
  end
  
  # Checks if we should crop the image.
   def cropping?
     !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
   end

   # Crops the image if the cropping values are set
   def crop!
     return false unless cropping?
     Magick::Image.read(full_filename).first.crop(crop_x.to_i, crop_y.to_i, crop_w.to_i, crop_h.to_i).write(full_filename)

     # Resize all the thumbnails
     resize_all
   end

   # Returns the size of of a given thumbnail with the name of +size+.
   def size_for_thumbnail(size)
     thumbnails.each do |thumb|
       return thumb if thumb.thumbnail == size.to_s
     end
   end  
  
end
