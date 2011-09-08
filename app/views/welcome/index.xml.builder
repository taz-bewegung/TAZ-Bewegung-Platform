cache("startpage-xml", :expires_in => 30.minutes) do
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
  xml.startpage do
    xml.title "Neues von der Bewegungsseite"
    xml.number_of_events DaysWithEvent.count(:conditions => "day >= now()")
    xml.latest_activity do
      xml.title Activity.active.latest.first.title      
      xml.url activity_url(Activity.active.latest.first)
    end
    xml.latest_organisation do
      xml.title Organisation.active.latest.first.title
      xml.url organisation_url(Organisation.active.latest.first)
    end
    xml.latest_location do
      xml.title Location.active.latest.first.title
      xml.url organisation_url(Location.active.latest.first)
    end
    xml.latest_activity_blog_entry do
      latest_activity_blog_post = BlogPost.published.for("Activity").recent.first
      xml.activity do
        xml.title latest_activity_blog_post.title
        xml.url activity_url(latest_activity_blog_post)
      end
      xml.title latest_activity_blog_post.blog.bloggable.title
      xml.url polymorphic_url([latest_activity_blog_post.blog.bloggable, latest_activity_blog_post])
    end
    xml.latest_organisation_blog_entry do
      latest_organisation_blog_post = BlogPost.published.for("Organisation").recent.first
      xml.organisation do
        xml.title latest_organisation_blog_post.title
        xml.url organisation_url(latest_organisation_blog_post)
      end
      xml.title latest_organisation_blog_post.blog.bloggable.title
      xml.url polymorphic_url([latest_organisation_blog_post.blog.bloggable, latest_organisation_blog_post])
    end
  end
end