module Search
  module Admin

    class Event < Base
    
      ORDER_OPTIONS =  [
                        ["Sort.: Titel", 'events.title'], 
                       ] unless defined?(ORDER_OPTIONS)
                     
      CONDITION_OPTIONS = [
                            ["Suche: Alles", "use_ferret"], 
                            ["Suche: Titel", 'title'],
                           ] unless defined?(CONDITION_OPTIONS)
    
      
      def search_without_ferret
        @order = 'title ASC' if @order.blank?                
        ::Event.paginate :conditions => @conditions_array, 
                            :order => @order, 
                            :page => page, 
                            :per_page => 30,
                            :include => [:image, :address]
      end
    
      def search_with_ferret
        @order = 'title ASC' if @order.blank?        
        ::Event.find_with_ferret query, { :page => page, 
                                             :per_page => 30
                                           }, 
                                           :include => [:image, :address],
                                           :conditions => @conditions_array,
                                           :order => @order

      end

    end
  end
end