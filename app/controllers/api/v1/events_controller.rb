=begin rapidoc
  name:: Termine
  json:: <%= CodeRay.encode(Event.first.api_hash.to_json, :json, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>
  xml:: <%= CodeRay.encode(Event.first.api_hash.to_xml(:root => :event), :xml, :html, :line_numbers => :table, :hint => :info, :css => :style, :wrap => :div) %>

  Über die API für Termine können neue Termine auf bewegung.taz.de angelegt werden. Zum Erstellen muss die unten angegebene URL mit einem HTTP-POST 
  aufgerufen werden. Die Parameter sind dabei als normale POST-Parameter zu übergeben.
    
=end

class Api::V1::EventsController < Api::V1Controller
  
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate
  

#  def index
#    @events = Event.all
#    respond_to do |format|
#      format.json { render :json => @events }
#      format.xml { render :xml => @events }
#    end
#  end


=begin rapidoc
  name:: Termine erstellen
  url:: /api/v1/termine
  method:: POST
  access:: Authorisierung erforderlich
  formats:: xml, json
  return:: Eine Antwort ob das Anlegen erfolgreich war oder eine Fehlermeldung
  
  param:: event[title] :: string :: <b>Benötigt</b>:: Der Titel des Termins
  param:: event[description] :: text :: <b>Benötigt</b> :: Der Beschreibungstext des Termins
  param:: event[event_type] :: string :: <b>Benötigt</b> :: Der Typ des Termins als Freitextfeld
  param:: event[starts_at] :: datetime :: Benötigt :: Der Startzeitpunkt des Termins (MEZ)
  param:: event[ends_at] :: datetime :: Optional :: Der Endzeitpunkt des Termins (MEZ)
  param:: event[website] :: string :: Optional :: Eine Website-URL des Termins
  param:: event[permalink] :: string :: Optional :: Das URL-Kürzel, unter welchem der Termin bei bewegung.taz.de zu erreichen ist
  param:: event[organisation_id] :: string :: Optional :: UUID der zugeghörigen Organisation (die Organisationen können <a href="/api/v1/docs/organisationen">hier</a> abgefragt werden)
  param:: event[organisation_name] :: string :: Optional :: Falls keine Organisation zugewiesen werden kann, der Organisationsname  
  param:: event[address_attributes][street] :: string :: Optional :: Straße + PLZ der Adresse des Termins
  param:: event[address_attributes][zip_code] :: string :: Optional :: PLZ der Adresse des Termins
  param:: event[address_attributes][city] :: string :: Optional :: Stadt des Termins
  param:: event[address_attributes][nationwide] :: boolean :: Optional :: Bundesweiter Termin  
  param:: event[social_category_ids][] :: string :: Optional :: UUIDs einer Kategorie (mehrere möglich)
  
  notes:: Termine werden automatisch dem angemeldeten Benutzer zugewiesen.
  samples:: curl -X POST -d \"event[title]=Testtermin&event[description]=Kleiner Test&event[starts_at]=2009-04-24T10:00:00+02:00&event[address_attributes][city]=Darmstadt\" <%= application.site_url %>/api/v1/termine.xml

  Durch einen HTTP-Post auf die URL lassen sich Termine erstellen.
=end  
  def create 
#    current_user = User.find_by_permalink "mike"
    @event = Event.new(params[:event]) 
    @event.originator = current_user
    
    valid_event = @event.validate_attributes(:only => [:title, :description, :website, :starts_at])
    
    respond_to do |format|
      if valid_event
        @event.api_time_handling = true
        @event.save(false)
        format.xml  { render :xml => @event.api_hash.to_xml, :status => :created, :location => @event }
        format.json  { head :ok } 
      else
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.json  { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
end
