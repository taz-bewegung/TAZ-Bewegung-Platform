# encoding: UTF-8
class ISearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods
  extend ActiveModel::Translation
  extend ActiveModel::Callbacks
  
  def to_param
    "1"
  end

  def persisted?
    false
  end
  
  ##
  # Constants
  RADIUS_OPTIONS = [
    [ "5km"  , "5" ],
    [ "10km" , "10" ],
    [ "20km" , "20" ],
    [ "50km" , "50" ], 
    [ "100km" , "100" ],
    [ "200km" , "200" ]
  ] unless defined? RADIUS_OPTIONS
  
  DATE_FILTER_OPTIONS = [
    [ "heute"  , "today" ],
    [ "in den nächsten 7 Tagen" , "week" ],
    [ "in den nächsten 4 Wochen" , "month" ],
    [ "individuelle Eingabe" , "custom" ]
  ] unless defined? DATE_FILTER_OPTIONS
  
  ##
  # Accessors
  attr_accessor :result, 
                :search_type, # Aktionen, Organisationen, Termine & Orte
                :query,       # Suchstring
                :category_id, # Kategorie
                :date_filter, # Zeitangabe
                :from_date,   # Von
                :to_date,     # Bis
                :place,       # Ort
                :radius,      # Umkreis, ausgehend von :place
                :conditions,
                :page,
                :location_category_id # Ortkategorien

  ##
  # Validations
#  validates_date :from_date, :on_or_before => :to_date,
#                             :if => Proc.new { not from_date.blank? }
#  validates_date :to_date, :on_or_after => :from_date,
#                           :if => Proc.new { not to_date.blank? }

  ##
  # Methods
  
  def after_initialize
    @search_query = @query.split(" ").collect{|term| "*" + term.gsub(/\./,"!.") + "*"}.join(" ") unless @query.blank?
    @search_query = "*" if @query.blank? 
    @search_type = "activities" if @search_type.blank? 
    self.valid?
  end
  
  def get_conditions(search_type = nil)
    type = search_type.nil? ? @search_type : search_type
    extend Search.const_get("#{type.to_s.singularize.classify}Search")
    prepare_conditions
  end
  
  # Finally do the search
  def do_search(search_type = nil)  
    type = search_type.nil? ? @search_type : search_type
    extend Search.const_get("#{type.to_s.singularize.classify}Search")
    
    search  # Call the search method from the included module
  end 
    
  def multi_search(page = nil)
    result = {}
    %w( activities organisations locations events ).each do |type|
      extend Search.const_get("#{type.to_s.singularize.classify}Search")

      if @search_type == type
        result[type.to_sym] = search(page)
      else
        result[type.to_sym] = search
      end
    end
    result
  end

end
