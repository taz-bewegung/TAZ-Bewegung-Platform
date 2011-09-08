module Search
  module Admin

    class User < Base
    
      ORDER_OPTIONS =  [
                        ["Sort.: Nachname", 'last_name'], 
                        ["Sort.: E-Mail", 'email'] 
                       ] unless defined?(ORDER_OPTIONS)

      CONDITION_OPTIONS = [
                            ["Suche: Alles", 1], 
                            ["Suche: Kurzname", 'permalink'],                             
                            ["Suche: Nachname", 'last_name'], 
                            ["Suche: Vorname", 'first_name'],
                            ["Suche: E-Mail", 'email'],
                            ["Suche: Beschreibung", 'about_me']
                           ] unless defined?(CONDITION_OPTIONS)
      
      def search_without_ferret
        ::User.paginate :conditions => @conditions_array, 
                              :order => order, 
                              :page => page, 
                              :per_page => 60,
                              :include => [:image, :address, :activities, :events]
      end
      
      def search_with_ferret
        ::User.find_with_ferret query, { :page => page, 
                                                 :per_page => 60
                                               }, 
                                                 :include => [:image, :address, :activities, :events],
                                                 :conditions => @conditions_array,
                                                 :order => order

      end

    end
  end
end