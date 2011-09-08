module Search
  module Admin

    class Location < Base
    
      ORDER_OPTIONS =  [
                        ["Sort.: Titel", 'locations.name'], 
                       ] unless defined?(ORDER_OPTIONS)
                     
      CONDITION_OPTIONS = [
                            ["Suche: Alles", "use_ferret"], 
                            ["Suche: Name", 'name'],
                           ] unless defined?(CONDITION_OPTIONS)
    
      
      def search_without_ferret
        @order = 'locations.name ASC' if @order.blank?                
        ::Location.paginate :conditions => @conditions_array, 
                            :order => @order, 
                            :page => page, 
                            :per_page => 60,
                            :include => [:image, :address]
      end
    
      def search_with_ferret
        @order = 'locations.name ASC' if @order.blank?        
        ::Location.find_with_ferret query, { :page => page, 
                                             :per_page => 60
                                           }, 
                                           :include => [:image, :address],
                                           :conditions => @conditions_array,
                                           :order => @order

      end

    end
  end
end