xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @bloggable.title
    #xml.description { xml.cdata!(@bloggable.description) }
    
    xml.language "de-de"
    xml.link polymorphic_url([@bloggable, :blog])
    xml.image do 
      xml.url image_url_for(@bloggable, :medium)
      xml.title @bloggable.title
    end
    
    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description { xml.cdata!(full_blog_post_content_for(post)) }
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link polymorphic_url([@bloggable, post])
        xml.guid post.id
      end
    end
  end
end
                                                            