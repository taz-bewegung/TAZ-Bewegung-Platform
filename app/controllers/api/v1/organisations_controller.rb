=begin rapidoc
  name:: Organisationen
  json:: <%= CodeRay.encode(Organisation.first.api_hash.to_json, :json, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>
  xml:: <%= CodeRay.encode(Organisation.first.api_hash.to_xml(:root => :organisation), :xml, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>

  Über die API für Organisationen können Organisationen auf bewegung.taz.de in verschiedenen Formaten exportiert werden.
    
=end

class Api::V1::OrganisationsController < Api::V1Controller

  skip_before_filter :verify_authenticity_token

=begin rapidoc
  name:: Organisationen auslesen
  url:: /api/v1/organisationen
  method:: GET
  access:: Authorisierung erforderlich
  return:: [JSON|XML] - Eine Liste mit Terminen
  param:: page :: integer :: Optional :: Die aktuelle Seite
  param:: per_page :: integer :: Optional :: Wie viele Organisationen sollen pro Seite angezeigt werden
  formats:: xml, json
  return:: Eine Liste mit Organisationen
  return_xml:: <%= CodeRay.encode(render(:partial => \"/api/v1/organisations/index.xml.builder\", :locals => { :organisations => Organisation.active.paginate(:page => 1, :per_page => 2) }), :xml, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>
  return_json:: <%= CodeRay.encode(Organisation.active.paginate(:page => 1, :per_page => 2).to_json, :json, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>  
  
  samples:: curl <%= application.site_url %>/api/v1/organisationen.xml?page=1&per_page=20

  Liefert eine Liste mit Organisationen zurück. Die Liste ist abhängig von den gewählten Parametern und dem gewählten Format.<br />
=end  
  def index
    @organisations = Organisation.active.paginate(:page => params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.json { render :json => @organisations }
      format.xml { render :partial => "index", :locals => { :organisations => @organisations } }
    end
  end
    
end
