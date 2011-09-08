module SearchesHelper
   
  def render_result_info(result, active) 
    primary = I18n.t :"search.main_sentence", :object => content_tag(:span, I18n.t("search."+active.to_s, :count => result[active].total_hits.to_i)), 
                                              :count => result[active].total_hits.to_i
    others = %w( activities organisations locations events ) - [active.to_s]
    others = others.map do |other| 
      params[:i_search].merge!({:search_type => other})      
      link_to content_tag(:span, I18n.t("search."+other.to_s, :count => result[other.to_sym].total_hits.to_i)), 
              url_for(params.merge!(:controller => "searches", :action => "show")) if result[other.to_sym].total_hits.to_i > 0 
    end.compact

    secondary = I18n.t :"search.other_sentence", :objects => others.to_a.to_sentence
    
    html = content_tag(:div, primary, :class => "finder-search-primary-result")
    html << content_tag(:div, secondary.to_s, :class => "finder-search-secondary-result") unless others.to_a.empty?
    html
  end
  
end
