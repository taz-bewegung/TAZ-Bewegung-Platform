# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include RoleRequirementSystem
  include Helpedia::SslRequirement
  include ExceptionNotifiable

  TAZ_TINY_MCE_OPTIONS = {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :theme_advanced_toolbar_location => "top",
    :theme_advanced_toolbar_align => "left",
    :paste_auto_cleanup_on_paste => true,
    :theme_advanced_buttons1 => %w( bold italic underline strikethrough separator justifyleft justifycenter justifyright separator bullist numlist separator link unlink undo redo ),
    :theme_advanced_buttons2 => [],
    :theme_advanced_buttons3 => [],
    :plugins => %w( paste )
  } unless defined? TAZ_TINY_MCE_OPTIONS

  # Prevent "fieldWithErrors"
  ActionView::Base.field_error_proc = proc { |input, instance| input }

  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password

#  before_filter :beta_check if RAILS_ENV == 'production'
  attr_accessor :cache_key

  before_filter :set_locale
  before_filter :setup_default
  before_filter :set_cache_key
  after_filter  :store_location, :except => [:create, :update, :delete]
  after_filter  :wikileaked
  after_filter :iranized

  rescue_from Exception, :with => :render_500 if RAILS_ENV == 'production'
  rescue_from Helpedia::UserIsNotOrganisation, :with => :render_401_not_organisation if RAILS_ENV == 'production'
  rescue_from Helpedia::UserIsNotUser, :with => :render_401_not_user if RAILS_ENV == 'production'
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404 if RAILS_ENV == 'production'
  rescue_from RuntimeError, :with => :render_500 if RAILS_ENV == 'production'
  rescue_from NoMethodError, :with => :render_500 if RAILS_ENV == 'production'
  rescue_from ActionController::UnknownAction, :with => :render_404 if RAILS_ENV == 'production'
  rescue_from ActionView::TemplateError, :with => :render_500 if RAILS_ENV == 'production'
  rescue_from ::ActionController::RoutingError, :with => :render_404 if RAILS_ENV == 'production'
  rescue_from ActionController::RoutingError, :with => :render_404 if RAILS_ENV == 'production'
  rescue_from Helpedia::ItemNotVisible, :with => :render_401_item_not_visible if RAILS_ENV == 'production'
  rescue_from Helpedia::PageNotAvailableAnymore, :with => :render_404 if RAILS_ENV == 'production'
  rescue_from WillPaginate::InvalidPage, :with => :render_404 if RAILS_ENV == 'production'

  protected

    def wikileaked
      session[:wikileaked] = true
    end

    def iranized
      session[:iranized] = true
    end

    def beta_check
      redirect_to beta_signups_path if session[:beta_user].blank?
    end

    def taz_tiny_mce_options
      {
        :theme => 'advanced',
        :theme_advanced_resizing => true,
        :theme_advanced_resize_horizontal => false,
        :theme_advanced_toolbar_location => "top",
        :theme_advanced_toolbar_align => "left",
        :paste_auto_cleanup_on_paste => true,
        :theme_advanced_buttons1 => %w( bold italic underline strikethrough separator justifyleft justifycenter justifyright separator bullist numlist separator link unlink undo redo ),
        :theme_advanced_buttons2 => [],
        :theme_advanced_buttons3 => [],
        :plugins => %w( paste )
      }
    end
    helper_method :taz_tiny_mce_options

    def include_gm_header
      @template.use_googlemaps
    end


    def render_401_not_organisation(e)
      #handle_exception(e)
      respond_to do |type|
        type.html { render :partial => "errors/error_401_not_organisation", :status => 401, :layout => "application" }
        type.lightbox { render :partial => "errors/lightbox_401_not_organisation", :status => 401 }
        type.all  { render :nothing => true, :status => "401 Not Found" }
      end
    end

    def render_401_item_not_visible(e)
      #handle_exception(e)
      respond_to do |type|
        type.html { render :partial => "errors/error_401_item_not_visible", :status => 401, :layout => "application" }
        type.all  { render :nothing => true, :status => "401 Not Found" }
      end
    end


    def render_401_not_user(e)
      #handle_exception(e)
      respond_to do |type|
        type.html { render :partial => "errors/error_401_not_user", :status => 401, :layout => "application" }
        type.lightbox { render :partial => "errors/lightbox_error_401_not_user" }
        type.js { render :partial => "errors/lightbox_error_401_not_user" }
        type.all  { render :nothing => true, :status => "401 Not Found" }
      end
    end

    def render_404(e)
      #handle_exception(e)
      respond_to do |type|
        type.html { render :partial => "errors/error_404", :status => 404, :layout => "application" }
        type.all  { render :nothing => true, :status => "404 Not Found" }
      end
    end

    def render_500(e)
     handle_exception(e)
     respond_to do |type|
        type.html { render :partial => "errors/error_500", :status => 500, :layout => "application" }
        type.all  { render :nothing => true, :status => "500 Error" }
      end
    end

    def plain_params
      params.clone.delete_if { |k, v| %w(controller action _method authenticity_token nice_url).include? k }
    end
    helper_method :plain_params

    def only_route_params
      params.clone.delete_if { |k, v| not %w(controller blog_id action user_id event_id organisation_id engagement_id job_id activity_id).include? k }
    end
    helper_method :only_route_params

    def handle_exception(exception)
      #params_to_send = (respond_to? :filter_parameters) ? filter_parameters(params) : params
      #Exceptional.handle(exception, self, request, params_to_send)

      # Email Notification
      deliverer = self.class.exception_data
      data = case deliverer
        when nil then {}
        when Symbol then send(deliverer)
        when Proc then deliverer.call(self)
      end
      ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
    end

    def set_locale
    end

    def setup_default
      I18n.reload! unless %w( production ahoi).include?(RAILS_ENV)
    end

    def set_cache_key
       cache_temp = params
       cache_temp.delete("_")
       @cache_key = Digest::MD5.hexdigest("#{cache_temp.to_a.sort.join('-')}")
    end

    def cached_fragment_exist?(cache_key, options)
      timestamp = CachingStats.date_for_key(cache_key)
      options[:key_parts] = [] if options[:key_parts].blank?
      options[:key_parts] << timestamp
      options[:key_parts].insert(0, request.format.to_s)
      key = "#{cache_key}/#{options[:key_parts].join('/')}"
      fragment_exist?(key)
    end

    ##
    # Render helper methods

    # Renders the index action for a specific type.
    # The options[:context] parameter defines which context to render.
    def render_index_in_context_for(type, options = {})
      respond_to do |format|
         format.html do
           render :partial => "/#{options[:context].to_s}/show/show",
                  :layout => true,
                  :locals => { :content_partial => "/#{type.to_s}/index/#{options[:context].to_s}/show" }
         end
         format.js { }
      end
    end


end

