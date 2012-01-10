# encoding: UTF-8
class CommendationsController < ApplicationController
  
  before_filter :find_commendable
  
  def index
    render :partial => "errors/error_404", :status => 404, :layout => "application"
  end

 def new
   @commendation = Commendation.new
   view_context.escape_javascript(render(:partial => "new"))
 end
 
 def create
   @commendation = Commendation.new(params[:commendation]) 
   @commendation.commendable = @commendable
   if @commendation.save
     render :update do |page|
       page['#nyroModalContent'].replace_html :partial => "submitted"
     end     
   else
     render :update do |page|
       page['#nyroModalContent'].replace_html :partial => "new"
     end
   end
 end
 
  private
 
    def find_commendable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @commendable =  $1.classify.constantize.find_by_permalink(value)
        end
      end      
    end
  
end
