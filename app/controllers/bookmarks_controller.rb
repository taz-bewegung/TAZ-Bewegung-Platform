# encoding: UTF-8
class BookmarksController < ApplicationController

  before_filter :login_required, :only => [:create, :destroy]
  before_filter :user_login_required, :only => [:create, :destroy]  
  before_filter :find_bookmarkable
  
  def index
    render :partial => "errors/error_404", :status => 404, :layout => "application"  
  end
  
  def create
    @bookmark = current_user.bookmarks.create :bookmarkable => @bookmarkable
    render :update do |page|
      page << "$.nyroModalManual(
  		{
   			bgColor: '#000000',
   			content: '#{ render(:partial => "/bookmarks/created").gsub("\n", '\ \n') }',
   			type: 'content',
   			width: 560,
   			height: 150
  		});"
  		page[".context-menu-items"].hide
      page["bookmark_#{@bookmarkable.id}"].replace_html view_context.link_to(I18n.t(:"context_menu.public.shared.bookmark.destroy"), 
                                                                          polymorphic_path([@bookmarkable, @bookmark]), 
                                                                          :class => "ajax-link-delete-without-confirm")
      page["bookmark_right_column_#{@bookmarkable.id}"].replace_html view_context.link_to(I18n.t(:"context_menu.public.shared.bookmark.destroy"), 
                                                                                       polymorphic_path([@bookmarkable, @bookmark]), 
                                                                                       :class => "ajax-link-delete-without-confirm")
    end
  end
  
  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @bookmark.destroy
    render :update do |page|
      page << "$.nyroModalManual(
  		{
   			bgColor: '#000000',
   			content: '#{ render(:partial => "/bookmarks/destroyed").gsub("\n", '\ \n') }',
   			type: 'content',
   			width: 560,
   			height: 150
  		});"
  		page[".context-menu-items"].hide  		
      page["bookmark_#{@bookmarkable.id}"].replace_html(view_context.link_to(I18n.t(:"context_menu.public.shared.bookmark.create"), 
                                                                          polymorphic_path([@bookmarkable, :bookmarks]), 
                                                                          :class => "ajax-link-post"))
      page["bookmark_right_column_#{@bookmarkable.id}"].replace_html(view_context.link_to(I18n.t(:"context_menu.public.shared.bookmark.create"), 
                                                                                       polymorphic_path([@bookmarkable, :bookmarks]), 
                                                                                       :class => "ajax-link-post"))
    end
  end
  
  private

    def find_bookmarkable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @bookmarkable =  $1.classify.constantize.find_by_permalink(value)
        end
      end
    end    
end
