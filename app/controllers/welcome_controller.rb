require 'open-uri'

class WelcomeController < ApplicationController
  
  caches_page :index, :if => Proc.new { |c| c.request.format.json? }
  
  layout 'home'
  before_filter :setup, :only => [:index]
  
  include ImageHelper
  

  def index 
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => render_json }
    end
  end

  
  def taz_rss
    @items = Rails.cache.fetch("taz_rss", :expires_in => 30.minutes) do
      begin
        items = Timeout::timeout(5) {
          rss = SimpleRSS.parse open('http://www.taz.de/rss.xml')
          rss.items
        }
      rescue Timeout::Error
        items = []
      end      
      YAML.dump(items.to_a)
    end
    @items = YAML.load(@items)
    render :update do |page|
      page['#taz-rss'].replace_html :partial => "taz_rss"
    end
  end
  
  def castor_rss
    @items = Rails.cache.fetch("taz_rss", :expires_in => 5.minutes) do
      begin
        items = Timeout::timeout(5) {
          rss = SimpleRSS.parse open('http://castorticker.de/taz/news.feed')
          rss.items
        }
      rescue Timeout::Error
        items = []
      end      
      YAML.dump(items.to_a)
    end
    @items = YAML.load(@items)
    render :update do |page|
      page['#taz-rss'].replace_html :partial => "castor_rss"
    end    
  end
  
  private
  
    def setup
      @template.main_menu :start
    end
    
    def render_json
      hash = Hash.new
      hash[:events] = {
        :count => Event.upcoming.count,
        :top10 => Event.upcoming.active.latest.limit(10).map { |e| { :title => e.title, 
                                                                     :url => event_url(e), 
                                                                     :start => e.starts_at.to_i, 
                                                                     :end => e.ends_at.to_i } }
      }
      hash[:activities] = {
        :count => Activity.running.active.count,
        :top10 => Activity.running.active.latest.limit(10).map { |a| { :title => a.title, 
                                                                       :url => activity_url(a) } }
      }
      hash[:organisations] = {
        :count => Organisation.active.count,
        :top10 => Organisation.active.latest.limit(10).map { |o| { :title => o.name, 
                                                                   :url => organisation_url(o) } }
      }
      hash[:locations] = {
        :count => Location.active.count,
        :top10 => Location.active.latest.limit(10).map { |l| { :title => l.title, 
                                                               :url => location_url(l) } }
      }
      
      hash[:blogposts] = {
        :count => BlogPost.published.count,
        :top10 => BlogPost.published.recent.limit(10).map { |p| { :title => p.title, 
                                                                  :url => polymorphic_url([p.blog.bloggable, p]),
                                                                  :author => p.blog.bloggable.title } if p.blog.present? }
      }
      hash
    end
end
