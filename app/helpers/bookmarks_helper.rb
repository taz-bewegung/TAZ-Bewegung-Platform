module BookmarksHelper
  
  def bookmark_icon_link_for(object, bookmark_type)
   return ""
   if not logged_in? or current_user.is_a?(Organisation)
      return ""
    end
        
    html = ""
    bookmark = object.bookmarked_by(current_user)
    if object.user_is_owner?(current_user)
      
    elsif bookmark.blank?
      icon = link_to image_tag("icons/bookmark-#{bookmark_type}-plus.png", :class => "bookmark"),
                                                bookmarks_path("bookmark[bookmarkable_type]" => object.class, 
                                                               "bookmark[bookmarkable_id]" => object.id,
                                                               :type => bookmark_type),
                                                :class => "ajax-link-post"
    else
      icon = link_to( image_tag("icons/bookmark-#{bookmark_type}-minus.png", :class => "bookmark"),
                                                { :controller => 'bookmarks', 
                                                  :action => 'destroy', 
                                                  :id => bookmark.id, 
                                                  :bookmark => { :bookmarkable_type => object.class, :bookmarkable_id => object.id },
                                                  :type => bookmark_type
                                                  
                                                },
                                                :class => "ajax-link-delete")
    end
    html = content_tag :div, icon, :id => "bookmark-image-link-wrap", :class => "bookmark-image-link-wrap"
  end  
  
  def bookmark_link_for(object, bookmark_type)
    return ""    
    if not logged_in? or current_user.is_a?(Organisation)
      return ""
    end
    
    html = ""
    bookmark = object.bookmarked_by(current_user)
    if object.user_is_owner?(current_user)
      
    elsif bookmark.blank?
      icon = link_to t(:"shared.public_profile.right_content.add_bookmark"),
                      bookmarks_path("bookmark[bookmarkable_type]" => object.class, 
                                      "bookmark[bookmarkable_id]" => object.id,
                                      :type => bookmark_type),
                                      :class => "ajax-link-post"
    else
      icon = link_to t(:"shared.public_profile.right_content.remove_bookmark"),
                                                { :controller => 'bookmarks', 
                                                  :action => 'destroy', 
                                                  :id => bookmark.id, 
                                                  :bookmark => { :bookmarkable_type => object.class, :bookmarkable_id => object.id },
                                                  :type => bookmark_type
                                                  
                                                },
                                                :class => "ajax-link-delete"
    end
    html = content_tag :li, icon, :id => "bookmark-link-wrap"    
  end
end
