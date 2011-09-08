cache("blog_posts/index/rss-#{@cache_key}", :expires_in => 30.minutes, :format => :xml) do
  xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
  xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
    xml.channel do
      xml.title       "Neue Blogeinträge auf bewegung.taz.de"
      xml.pubDate     CGI.rfc1123_date(@blog_posts.first.updated_at) if @posts.present?
      #xml.description "Von der kleinen kreativen Aktion, bis zur großen bundesweiten Kampagne. Hier können sich alle aktiv einbringen, sich austauschen und gemeinsam Projekte starten. Bewegte Menschen, Initiativen und Organisationen können sich vernetzen und dann zusammen ihre Ideen für eine bessere Welt in die Tat umsetzen."
      xml.language "de-de"
      @blog_posts.each do |post|
        xml.item do
          xml.title       post.title
          xml.link        polymorphic_url([post.blog.bloggable, post])
          #xml.description image_for(post, :large).to_s + post.goal.to_s
          xml.pubDate     CGI.rfc1123_date(post.created_at)
          xml.guid        polymorphic_url([post.blog.bloggable, post])
          xml.author      post.blog.bloggable.owner.full_name
        end
      end
    end
  end
end