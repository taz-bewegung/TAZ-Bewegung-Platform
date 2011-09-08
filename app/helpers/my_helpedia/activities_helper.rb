# encoding: UTF-8
module MyHelpedia::ActivitiesHelper
  
    def my_helpedia_activity_sub_menu(active)
    items = []                    
#    items << { :name => 'Übersicht', :link_to => my_helpedia_activity_path(@activity), :id => :overview  }
    items << { :name => 'Aktionsprofil', :link_to => edit_my_helpedia_activity_path(@activity), :id => :profile }
    items << { :name => 'Aktionsblog',
               :link_to => my_helpedia_activity_blog_path(@activity), 
               :id => :blog }
    items << { :name => 'Sympathisanten',
               :link_to => my_helpedia_activity_activity_memberships_path(@activity), 
               :icon => @activity.activity_memberships.pending.count,
               :id => :activity_memberships }  unless @activity.activity_memberships.blank?
    items << { :name => 'Kommentare', 
               :link_to => no_blog_my_helpedia_activity_comments_path(@activity), 
               :id => :comments } if @activity.comments.present?
    render :partial => "/menu/sub_menu", :locals => { :menu_items => items, :active => active}    
  end
    

  def my_helpedia_activity_context_menu(activity)
    items = []                    
    items << { :name => "... Aktion bearbeiten", 
               :link_to => edit_my_helpedia_activity_path(activity),
               :id => "edit_activity_#{activity.id}" }
    items << { :name => "... Aktion löschen", 
              :link_to => destroy_confirmation_my_helpedia_activity_path(activity),
              :options => { :class => "remote-link" },              
              :id => "delete_activity#{activity.id}" }
    render :partial => "/menu/context_menu", :locals => { :menu_items => items }
  end  
  
  

end
