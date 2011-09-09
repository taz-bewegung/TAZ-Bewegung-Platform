# encoding: UTF-8
class ContentsController < ApplicationController

  before_filter :user_login_required
  access_control :DEFAULT => '(admin | news)'
  
  ##
  # Misc methods
  def edit_texts
    cookies[:edit_texts] = cookies[:edit_texts] == "1" ? "0" : "1"
    redirect_to :back
  end
  
  def get_data
    @collection = params[:type].to_class.active.latest.latest.limit(50).map{ |e| [e.title, e.id]}
    render :text => @template.options_for_select([["Kein Element ausgewählt", ""]] + @collection)
  end  
  
  def destroy_image
    Content::WelcomePageTeaserImage.find(params[:id]).destroy
    render :update do |page|
      page << "alert('Bild gelöscht! Bitte Formular neu laden.')";
    end
  end
  

  def edit_teaser_text
    @content = Content::TeaserText.find(params[:id])
    render :update do |page|
      page << "$.nyroModalManual(
      {
      	content: '#{ @template.escape_javascript(render(:partial => @content.class::EDIT_TEMPLATE)) }',
      	type: 'content', width: 550, height: 400,	bgColor: '#000000'
      });"
    end
  end
  
  def save_teaser_text
    @content = Content::TeaserText.find(params[:id])
    @content.attributes = params[:content_teaser_text]
    @content.save
    render :update do |page|
      page << "$.nyroModalRemove();"
      page[@content].replace :partial => @content.class::PUBLIC_TEMPLATE, :locals => { :content => ContentElement.find_by_element_id(@content.id), 
                                                                                       :options => { :cache_fragment => params[:cache_fragment]} }
    end
    
    # Expire cache
    expire_fragment(params[:cache_fragment])
  end
  
  
  ##
  # Teaser carousel

  def edit_landing_carousel
    @container = Container.find(params[:id])
    render :update do |page|
      page << "$.nyroModalManual(
      {
      	content: '#{ @template.escape_javascript(render(:partial => "/content/landing_page/edit_carousel")) }',
      	type: 'content', width: 550, height: 400,	bgColor: '#000000'
      });"
    end
  end
  
  def save_landing_tab
    @content = Content::LandingPageTab.find(params[:id])
    @content.attributes = params[:content_landing_page_tab]
    @content.save
    render :update do |page|
      page << "alert('Gespeichert! Bitte die Seite neu laden zum Anzeigen der Änderungen.');"
    end
    # Expire cache
    expire_fragment(params[:cache_fragment])    
  end
  
  
  ##
  # Top elements
  
  def edit_top_element
    @content = Content::TopElement.find(params[:id])
    render :update do |page|
      page << "$.nyroModalManual(
      {
      	content: '#{ @template.escape_javascript(render(:partial => "/content/start_page/edit_top_element")) }',
      	type: 'content', width: 550, height: 400,	bgColor: '#000000'
      });"
    end    
  end
  
  def save_top_element
    @content = Content::TopElement.find(params[:id])
    @content.attributes = params[:content_top_element]
    @content.save
    render :update do |page|
      page << "$.nyroModalRemove();"
      page[@content].replace :partial => "/content/start_page/top_element", :locals => { :content => ContentElement.find_by_element_id(@content.id) }
    end     
    
    # Expire cache
    expire_fragment("welcome_index")
  end  
  
  
  ###
  # Welcome carousel
  
  ##
  # Teaser carousel

  def edit_welcome_carousel
    @container = Container.find(params[:id])
    render :update do |page|
      page << "$.nyroModalManual(
      {
      	content: '#{ @template.escape_javascript(render(:partial => "/content/start_page/edit_carousel")) }',
      	type: 'content', width: 550, height: 600,	bgColor: '#000000'
      });"
    end
  end
  
  def save_welcome_carousel
    @content = Content::WelcomePageTeaser.find(params[:id])
    @content.attributes = params[:content_welcome_page_teaser]
    @content.image = Content::WelcomePageTeaserImage.new(params[:content_welcome_page_teaser_image]) unless params[:content_welcome_page_teaser_image].blank?
    @content.save
    responds_to_parent do
      render :update do |page|
        page << "alert('Gespeichert! Bitte die Seite neu laden zum Anzeigen der Änderungen.');"
      end
    end
    # Expire cache
    expire_fragment(params[:cache_fragment])
    expire_fragment("welcome_index")    
  end
  
  
  
  
end
