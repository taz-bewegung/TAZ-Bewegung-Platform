class SearchesController < ApplicationController

  include ImageHelper
  include GoogleMapsHelper

  skip_before_filter :verify_authenticity_token
  before_filter :setup_params
  before_filter :include_gm_header
  
  ssl_allowed :show, :create, :change_view

  def show
    create
  end
  
  def create
    @search = ISearch.new(params[:i_search])
    @result = @search.multi_search(params[:page])
    
    render :action => :create
  end
  
  def change_view
    @search = ISearch.new(params[:i_search])
    @result = @search.multi_search(params[:page])
    build_map(@result[params[:i_search][:search_type].to_sym] ,:width => 655, :height => 400) if params[:list_type] == "maps"
  end
  
  private
  
    def setup_params
      params[:list_type] = :cards if params[:list_type].blank? or not %w( cards rows maps ).include?(params[:list_type])
      params[:page] ||= 1
    end
  
end
