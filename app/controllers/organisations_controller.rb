# encoding: UTF-8
class OrganisationsController < ApplicationController

  include ImageHelper
  include GoogleMapsHelper

  before_filter :setup
  before_filter :setup_params, :include_gm_header, :only => [:index]
  before_filter :find_organisation, :only => [:show, :facts, :about]
  before_filter :check_for_user, :only => [:new, :create]
  before_filter :get_partial_organisation_from_session, :only => [:new, :create]
  before_filter :clear_step_errors, :only => [:create]

  skip_before_filter :store_location, :only => [:registered]
  uses_tiny_mce :only => [:new, :create], :options => TAZ_TINY_MCE_OPTIONS

  ssl_required :new, :create, :registered

  def index
    conditions = ['organisations.state = "active"']

    if (params[:i_search]) then
      i_search = ISearch.new(params[:i_search])
      conditions = i_search.get_conditions
    end
    conditions.add_condition ["organisations.corporate_form_id = ?", params[:category]] unless (params[:category]).blank?
    @organisations = Organisation.active.paginate(:page => params[:page],
                                                  :order => order,
                                                  :conditions => conditions,
                                                  :per_page => @per_page,
                                                  :include => [:image, :address, :social_category_memberships])

    build_map(@organisations, :width => 660, :height => 400, :max_visible_markers => 250) if params[:list_type] == "maps"
    @cache_key = cache_key
    respond_to do |format|
      format.html do
        render 'organisations/_index', :layout => true
      end
      format.js do
        render :action => :index
      end
      format.xml
    end
  end

  def show
    redirect_to about_organisation_path
    #respond_to do |format|
    #  format.html { render_partial_for_html("/organisations/show/overview") }
    #  format.js { render_partial_for_js("/organisations/show/overview") }
    #end
  end

  def about
    respond_to do |format|
      format.html { render_partial_for_html("/organisations/show/about") }
      format.js { render_partial_for_js("/organisations/show/about") }
    end
  end

  def facts
    respond_to do |format|
      format.html { render_partial_for_html("/organisations/show/facts") }
      format.js { render_partial_for_js("/organisations/show/facts") }
    end
  end

  def new
    session[:organisation_presenter] = nil
    @presenter = OrganisationRegistrationPresenter.new(params[:organisation_registration_presenter])
    @organisation = Organisation.new
    @address = Address.new
  end

  def create
    if (params[:step])
      @presenter.go_to_step(params[:step])
    else
      @presenter = @presenter.merge(params[:organisation_registration_presenter])
      saved = @presenter.save
    end

    if saved
      @presenter = nil
      redirect_to registered_organisations_path
    else
      session[:organisation_presenter] = @presenter unless @presenter.nil?
      render :action => :new
    end
  end

  def registered
    @session = Session.new
  end

  private


    # Checks if the activity can be shown to the public.
    # Otherwise a 404 is thrown.
    def check_visibility
      if not @organisation.active?
        hidden = false
        if not current_user == @organisation
          hidden = true
        end

        current_user.is_a?(User) and current_user.has_role?(:admin) ? hidden = false : nil
        if hidden
          raise Helpedia::ItemNotVisible
        end
      end
    end


    def find_organisation
      @organisation = Organisation.find_by_permalink(params[:id], :include => :address)
      raise ActiveRecord::RecordNotFound if @organisation.blank?
      raise Helpedia::ItemNotVisible unless @organisation.visible_for?(current_user)

    end

    def render_partial_for_html(partial)
      render "/organisations/show/_show",
             :layout => true,
             :locals => { :content_partial => partial }
    end

    def render_partial_for_js(partial)
      render :update do |page|
        page['sub-content-wrap'].replace_html :partial => partial
      end
    end

    def setup
      view_context.main_menu :organisations
    end

    def check_for_user
      redirect_back_or_default("/") if current_user
    end

    def setup_params
      params[:list_type] = if ["cards","rows", "maps"].include? params[:list_type] then params[:list_type] else "cards" end
      @per_page = if params[:list_type] == "maps" then 10000 else 20 end
      params[:order] = "random" if params[:order].blank?
      params[:page] = 1 if params[:page].blank? or params[:pagination_reload] == "1"
      params[:order] = "newest" if request.format.xml?
    end

    def get_partial_organisation_from_session
      @presenter = session[:organisation_presenter] || OrganisationRegistrationPresenter.new(params[:organisation_registration_presenter])
      if params[:current_step] then @presenter.current_step = params[:current_step] end
    end

    def clear_step_errors
      session[:organisation_presenter].errors.clear unless session[:organisation_presenter].nil?
    end


    def order
      case params[:order]
        when "title"                     then "organisations.name ASC"
        when "newest"                    then "organisations.created_at DESC"
        when "last_update"               then "organisations.updated_at DESC"
        when "random"                    then "rand()"
        when nil                         then 'organisations.name ASC'
      end
    end
end