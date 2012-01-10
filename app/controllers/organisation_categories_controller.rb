# encoding: UTF-8
class OrganisationCategoriesController < ApplicationController

  before_filter :setup

  def index
    unless fragment_exist?("organisation_categories/index")    
      @latest_organisations = Organisation.find( :all,:limit=>2, :order=> 'rand()', :conditions => ["state = 'active' AND length(description)> ?", 100])
      @categories =  SocialCategoryMembership.find(:all, :group => 'social_category_id', 
                                                         :conditions => ['member_type = ?','Organisation'], 
                                                         :include => ['social_category'], :order => 'social_categories.title ASC')
    end
    render :partial => "/organisation_categories/index", :layout => true

  end

  private

    def setup
      view_context.search_default :organisations      
    end

end
