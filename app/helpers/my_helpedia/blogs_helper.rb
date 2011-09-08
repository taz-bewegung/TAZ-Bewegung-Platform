module MyHelpedia::BlogsHelper

  def my_helpedia_blog_sub_menu(active)
    items = []                    
    items << { :name => "Öffentlichte Einträge (#{@bloggable.blog.posts.published.count.to_i})", 
               :link_to => polymorphic_path([:my_helpedia, @bloggable, :blog], { :state => :published }), 
               :id => :published_posts, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => "Versteckte Einträge (#{@bloggable.blog.posts.unpublished.count.to_i})", 
               :link_to => polymorphic_path([:my_helpedia, @bloggable, :blog], { :state => :unpublished }), 
               :id => :unpublished_posts, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => "Kommentare" , 
               :link_to => url_for([:my_helpedia, @bloggable, :comments].compact), 
               :id => :comments, 
               :options => { :class => "custom-button-33-message-none remote-link", :rel => "spinner" } }
    items << { :name => 'Neuer Blogeintrag', 
               :link_to => url_for([:new, :my_helpedia, @bloggable, :blog_post].compact),
               :id => :new, 
               :class => "right",               
               :options => { :class => "custom-button-33-beige remote-link", :rel => "spinner" } }
   items << { :name => image_tag("spinner.gif"), 
              :id => :spinner,
              :style => "display: none; padding-top: 7px;" }               
    items    
    render :partial => "/menu/sub_sub_button_menu", :locals => { :menu_items => items, :active => active}
  end 

end
