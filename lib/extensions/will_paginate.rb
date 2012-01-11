module WillPaginate
  module ViewHelpers

    # Renders a helpful message with numbers of displayed vs. total entries.
    # You can use this as a blueprint for your own, similar helpers.
    #
    # <%= page_entries_info @posts %>
    # #-> Displaying posts 6 - 10 of 26 in total
    #
    # By default, the message will use the humanized class name of objects
    # in collection: for instance, "project types" for ProjectType models.
    # Override this to your liking with the <tt>:entry_name</tt> parameter:
    #
    # <%= page_entries_info @posts, :entry_name => 'item' %>
    # #-> Displaying items 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name]
      entry_names = options[:entry_names]      
  
      if collection.total_pages < 2
        case collection.size
        when 0; "Keine #{entry_name} gefunden"
        when 1; "Zeige <b>1</b> #{entry_name}"
        else; "Zeige <b>alle #{collection.size}</b> #{entry_names}"
        end
      else
        %{Zeige #{entry_names} <b>%d&nbsp;-&nbsp;%d</b> von <b>%d</b>} % [
          collection.offset + 1,
          collection.offset + collection.length,
          collection.total_entries
        ]
      end
    end
    
    def page_selector(collection, options = {})
      options = (1..collection.total_pages).map { |p| ["#{p}", p] }
      if collection.total_pages < 1
        options = [["1", 1]]
      end
      select_tag('go_to',  link_options_for_select(options, params[:page]))
    end
    
    
    private
    
    def link_options_for_select(container, selected = nil)
      container = container.to_a if Hash === container

      options_for_select = container.inject([]) do |options, element|
        text, value = option_text_and_value(element)
        selected_attribute = ' selected="selected"' if params[:page].to_s == value.to_s
        url = url_for(url_options(value))
        options << %(<option  value="#{html_escape(text.to_s)}"#{selected_attribute}>#{html_escape(text.to_s)}</option>)
      end

      options_for_select.join("\n")
    end
    
    def url_options(page = 1)
      options = { :page => page }
      options = params.merge(options)
      return options
    end

  end
  
  class Collection
    def update_total_pages(pages)      
      @total_pages = pages
    end  
  end
end