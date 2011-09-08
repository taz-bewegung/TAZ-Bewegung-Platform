module DocumentsHelper
  
  def document_for(object)
    html = ""
    unless object.document.blank?
      html << link_to(image_tag(object.document.media_type_icon), object.document.public_filename)
      html << link_to(object.document.filename, object.document.public_filename)
    else
      html << "-"
    end
    html
  end
  
  def document_sub_menu_items
    items = []                    
    items << { :name => "Dokument hochladen", 
               :link_to => new_document_path(:part => params[:part]), 
               :id => :new,
               :options => { :class => "ajax-link" } }
    items << { :name => "Meine Dokumente", 
              :link_to => documents_path(:part => params[:part]), 
              :id => :index,
              :options => { :class => "ajax-link" } }               
    items    
  end
  
  def document_sub_menu(active, options = {})
    render :partial => "/menu/sub_menu", :locals => { :menu_items => document_sub_menu_items, :active => active }
  end  
  
end
