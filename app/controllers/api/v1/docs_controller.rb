# encoding: UTF-8
require 'coderay'

class Api::V1::DocsController < ApplicationController
  
  before_filter :setup_params
  
  private
  
    def setup_params
      params[:per_page] = 2 if params[:per_page].blank?
      params[:page] = 1 if params[:page].blank?      
    end
  
end
