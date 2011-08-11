module Search
  module Admin

    class Base < ActiveRecord::BaseWithoutTable
    
      attr_accessor :search_word
      attr_accessor :order
      attr_accessor :conditions
      attr_accessor :conditions_array
      attr_accessor :page
      attr_accessor :query
      attr_accessor :user_ferret
      
      def initialize(options = {})
        super options
        @conditions_array = []
        @order = options[:order]
        if options[:conditions] == "use_ferret"
          @use_ferret = true
          setup_options_with_ferret(options)
        else
          @use_ferret = false          
          setup_options_without_ferret(options)          
        end        
      end
      
      def search(page = 1)
        @page = page        
        if @use_ferret
          search_with_ferret
        else
          search_without_ferret          
        end        
      end
      
      def add_condition(condition)
        @conditions_array.add_condition(condition)
      end
      
      private
      
        def setup_options_with_ferret(params)
          if params[:search_word].blank? 
            @query = "*"
          else
            @query = params[:search_word].split(" ").collect{|term| "*" + term.gsub(/\./,"!.") + "*"}.join(" ")                
          end          
        end
        
        def setup_options_without_ferret(params)
          unless params[:search_word].blank? 
            query = params[:search_word].split(" ").collect{|term| "%" + term.gsub(/\./,"!.") + "%"}.join(" ")
            @conditions_array.add_condition(["#{params[:conditions]} LIKE ?", query])
          end          
        end

    end
  end
end