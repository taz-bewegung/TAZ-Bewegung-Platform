module Search
  module Admin

    class Organisation < Base
      
      
      
      ORDER_OPTIONS =  [
                        ["Sort.: Name", 'organisations.name'], 
                        ["Sort.: Status", 'organisations.state'], 
                        ["Sort.: E-Mail", 'contact_email'] 
                       ] unless defined?(ORDER_OPTIONS)
                     
      CONDITION_OPTIONS = [
                            ["Suche: Alles", "use_ferret"], 
                            ["Suche: Name", 'organisations.name'],
                            ["Suche: Ansprechpartner", 'contact_name'],
                            ["Suche: E-Mail", 'organisations.email'],
                            ["Suche: Beschreibung", 'about']
                           ] unless defined?(CONDITION_OPTIONS)
    
      
      def search_without_ferret
        ::Organisation.paginate :conditions => @conditions_array, 
                                :order => order, 
                                :page => page, 
                                :per_page => 30,
                                :include => [:image, :address, :activities, :events]
      end
    
      def search_with_ferret
        ::Organisation.find_with_ferret query, { :page => page, 
                                                 :per_page => 30
                                               }, 
                                               :include => [:image, :address, :activities, :events],
                                               :conditions => @conditions_array,
                                               :order => order

      end 
    end
  end
end