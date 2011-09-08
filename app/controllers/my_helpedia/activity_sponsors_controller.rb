class MyHelpedia::ActivitySponsorsController < ApplicationController
  
   before_filter :find_activity
   before_filter :login_required
   
   # Use SSL for those actions
   ssl_required :new, :create, :edit, :update, :cancel_edit_part, :destroy   
   
   def new   
     @activity_sponsor = @activity.activity_sponsors.new    
     @form_url = my_helpedia_activity_activity_sponsors_path(@activity, :part => @activity_sponsor.object_id)
     render :update do |page|
       page.insert_html :after, 'create_sponsor', :partial => "form"
       page << "$('##{params[:spinner]}').toggle();"       
     end
   end 
   
   def create
     @activity_sponsor = ActivitySponsor.new(params[:activity_sponsor])
     @form_url = my_helpedia_activity_activity_sponsors_path(@activity, :part => @activity_sponsor.object_id)    
     @activity_sponsor.activity = @activity
     if @activity_sponsor.save    
       if params[:image]
         @activity_sponsor.image = Image.find(params[:image])
       end       
       render :update do |page|
         page[params[:part]].replace_html :partial => "item", :locals => { :activity_sponsor => @activity_sponsor }
       end
     else
       if params[:image]
         @activity_sponsor.temp_image = Image.find(params[:image])
       end       
       render :update do |page|
         page[params[:part]].replace_html :partial => "form"
       end      
     end
   end

   def edit
     @activity_sponsor = @activity.activity_sponsors.find(params[:id])    
     @form_url = my_helpedia_activity_activity_sponsor_path(@activity, @activity_sponsor, :part => @activity_sponsor.object_id)        
     render :update do |page|
       page[params[:part]].replace_html :partial => "form"
       page << "$('##{params[:spinner]}').toggle();"       
     end    
   end

   def update
     @activity_sponsor = @activity.activity_sponsors.find(params[:id]) 
     @form_url = my_helpedia_activity_activity_sponsor_path(@activity, @activity_sponsor, :part => @activity_sponsor.object_id)            
     if @activity_sponsor.update_attributes(params[:activity_sponsor])    
       if params[:image]
         @activity_sponsor.image = Image.find(params[:image])
       end       
       render :update do |page|
         page[params[:part]].replace_html :partial => "item", :locals => { :activity_sponsor => @activity_sponsor }
       end
     else
       if params[:image]
         @activity_sponsor.temp_image = Image.find(params[:image])
       end       
       render :update do |page|
         page[params[:part]].replace_html :partial => "form"
       end      
     end    
   end

   def cancel_edit_part
     if params[:id] != "0"
       @activity_sponsor = @activity.activity_sponsors.find(params[:id]) 
       render :update do |page|
         page[params[:part]].replace_html :partial => "item", :locals => { :activity_sponsor => @activity_sponsor }
       end    
     else
       render :update do |page|
         page[params[:part]].remove
       end      
     end
   end

   def destroy
     activity_sponsor = @activity.activity_sponsors.find(params[:id])     
     activity_sponsor.destroy
     render :update do |page|
       page[params[:part]].remove
     end    
   end     
   
   
   private
   
    def find_activity
      @user = current_user
      @activity = @user.activities.find_by_permalink(params[:activity_id])
    end
  
end
