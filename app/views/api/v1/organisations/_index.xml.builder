xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.organisations :page => params[:page], :per_page => params[:per_page] do
  organisations.each do |organisation|
    xml << organisation.api_hash.to_xml(:skip_instruct => true, :root => :organisation)
  end
end
