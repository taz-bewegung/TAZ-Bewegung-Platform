xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.social_categories :page => params[:page], :per_page => params[:per_page] do
  social_categories.each do |category|
    xml << category.api_hash.to_xml(:skip_instruct => true, :root => :social_category)
  end
end
