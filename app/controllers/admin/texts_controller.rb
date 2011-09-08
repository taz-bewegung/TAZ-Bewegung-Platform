class Admin::TextsController < ApplicationController
  
  layout 'admin'
  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'  

  def index
  end

  def edit
    @text = Admin::Text.new(params[:id])
  end

  def update
    @text = Admin::Text.new
    @text.data = params[:text].stringify_keys
    @text.save_to(params[:id])
    redirect_to admin_texts_path
  end

end
