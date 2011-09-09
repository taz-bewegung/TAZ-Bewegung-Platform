# encoding: UTF-8
class PetitionUsersController < ApplicationController
  before_filter :find_activity
  before_filter :create_brain_buster, :only => [:activate]

  def index
    if @activity.wikileaked?
      @petition_users = PetitionUser.activated.latest.paginate(:page => params[:page], :per_page => 20)
    else
      @petition_users = IranPetitionUser.activated.latest.paginate(:page => params[:page], :per_page => 20)
    end
    @grouped_petition_users = @petition_users.group_by { |e| I18n.l(e.activated_at.to_date, :format => "%d. %B %Y") }
    respond_to do |format|
      format.html do
        session[:petition_date] = nil
        content_partial = @activity.active_petition? ?  "/petition_users/index" : "/petition_users/finished"
        render :partial => "/activities/show/show", 
               :layout => true,
               :locals => { :content_partial => content_partial, :sub_menu_active => :petition_users }
      end
      format.js do
        render :partial => "/petition_users/list" if @activity.active_petition?
      end
    end
  end

  def activate
    @comment = Comment.new
    @commentable_item = @activity
    @activating = true
    render :partial => "/activities/show/show", 
                       :layout => true, 
                       :locals => { :content_partial => "/activities/show/description", :sub_menu_active => :description }
  end

  protected

  def find_activity
    @activity = Activity.find_by_permalink(params[:activity_id])
    raise ActiveRecord::RecordNotFound if @activity.blank? or not (@activity.wikileaked? || @activity.iranized?)
  end
end
