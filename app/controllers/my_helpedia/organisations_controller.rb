class MyHelpedia::OrganisationsController < ApplicationController

  before_filter :find_organisation
  before_filter :setup
  before_filter :login_required  
  before_filter :organisation_login_required
  
  uses_tiny_mce :only => [:edit, :new, :create], :options => TAZ_TINY_MCE_OPTIONS
  
  # Use SSL for those actions
  ssl_required :index, :new, :create, :edit, :show, :description, :update, :cancel_edit_part, :destroy, :delete_country,
               :edit_part, :destroy, :destroy_confirmation
  
  def show
    redirect_to edit_my_helpedia_organisation_path(@organisation)
#     respond_to do |format|
#       format.html { render_partial_for_html("/my_helpedia/organisations/show/overview") } 
#       format.js { render_partial_for_js("/my_helpedia/organisations/show/overview") }       
#     end    
   end
   
   def edit
     respond_to do |format|
       format.html { render_partial_for_html("/my_helpedia/organisations/edit/edit") } 
       format.js { render_partial_for_js("/my_helpedia/organisations/edit/edit") }
     end    
   end
   
   def destroy_confirmation
   end
   
   def destroy
     current_user.destroy
     reset_session
     render :update do |page|
       page << "window.location.href='#{root_url}'" 
     end
   end
   
   def cancel_edit_part
     render :update do |page|
       page[params['part']].replace :partial => "/my_helpedia/organisations/edit/#{params['part']}"
     end
   end

   def edit_part
     render :update do |page|
       page[params['part']].replace :partial => "/my_helpedia/organisations/edit/edit_#{params['part']}"
       page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"       
     end    
   end
   
   def update
     replace, partial = params['part'], params['part']
     
     # Save the address if delivered
     unless params[:address].blank?
       @organisation.address.attributes = params[:address] 
       @organisation.address.save_with_validation(false)
     end  
     

     # Save image if delivered
     unless params[:image].blank?
       @organisation.image = Image.find(params[:image])       
     end     
     
     # Validate the different attributes 
     fields = case params[:part]
              when "contacts" then [:name]
              when "about" then [:description]
              when "address" then [:phone_area_code, :fax_area_code, :phone_country_code, :fax_country_code, :phone_number, :fax_number]
              when "profile_settings" then [:password, :password_confirmation]
              when "organisation_data" then [:name, :email, :website, :corporate_form_id]
              when "bank_data" then [:name]
              when "operation_area" then [:main_category_id]                
              when "additional_data" then [:name]
              end
     
     @organisation.attributes = params[:organisation]
     if @organisation.validate_attributes(:only => fields)

       if @organisation.changed? or @organisation.address.changed?
         OrganisationChangeEvent.create :trigger => @organisation, :operator => @organisation, :changes => @organisation.changes.merge(@organisation.address.changes)
       end
       
       # Finally save
       @organisation.save_with_validation(false)
       @organisation.reload
       
       render :update do |page|
         page[replace].replace :partial => "/my_helpedia/organisations/edit/#{partial}"
       end    
     else
       render :update do |page|
         page[replace].replace :partial => "/my_helpedia/organisations/edit/edit_#{partial}"
         page << "#{raw_tiny_mce_init(taz_tiny_mce_options)}"         
       end      
     end
   end
   
   private 

     def render_partial_for_html(partial)
       render :partial => "/my_helpedia/organisations/show/show", 
                          :layout => true, 
                          :locals => { :content_partial => partial }
     end

     def render_partial_for_js(partial)
       render :update do |page|
         page['sub-content-wrap'].replace_html :partial => partial
       end    
     end
  
    def find_organisation
      @organisation = current_user
      
      if @organisation.address.nil?
        @organisation.address = Address.new
      end
    end
  
    def setup
      view_context.main_menu :my_helpedia
    end
  
end
