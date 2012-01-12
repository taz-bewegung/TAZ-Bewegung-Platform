Bewegung::Application.routes.draw do

  #match '/kontakt' => 'feedbacks#contact'

  # Feed Events
  resources :feed_events

  # User & Sessions
  resource :session
  match 'logout' => 'sessions#destroy'
  match 'login' => 'sessions#new'
  match 'register' => 'sessions#create'
  match 'reset_password/:key' => 'sessions#reset_password', :key => nil
  match 'forgot_password' => 'sessions#forgot_password'  
  match 'forget_password' => 'sessions#forget_password'
  match 'change_password' => 'sessions#change_password'
  match 'password_changed' => 'sessions#password_changed'

  resources :users do

    member do
      get :edit_part
      put :save_part
      put :set_password
      get :edit_password
      get :delete_fairdouser
    end

    collection do
      get :split
      get :registered
    end

    resource :feedback

    resources :activities
    resources :locations
    resources :engagements
    resources :events
    resources :messages
    resources :friendships
    resources :external_profile_memberships

    resources :activity_memberships do
      collection do
        get :view
      end
    end

  end

  # Old Helpedia Stuff, to be renamed

  match 'my_helpedia' => 'my_helpedia#index'

  # Request
  resource :request

  # Newsletter
  match 'unsubscribe_newsletter' => 'newsletter#unsubscribe'
  match 'unsubscribed_newsletter' => 'newsletter#unsubscribed'   

  match 'subscribe_newsletter' => 'newsletter#subscribe'
  match 'subscribed_newsletter' => 'newsletter#subscribed'
  match 'confirm_newsletter/:id' => 'newsletter#confirm', :id => nil  
  match 'confirmed_newsletter' => 'newsletter#confirmed'

  # Flyers
  resources :flyer_orders

  # Commendations
  resources :commendations

  namespace :my_helpedia do

    resources :activity_memberships do
      collection do
        get :view
      end
    end

    resources :users do
      member do
        get :edit_part
        get :cancel_edit_part
        get :destroy_confirmation
      end
    end

    resources :external_profile_memberships do
      member do
        get :cancel_edit_part
      end
    end

    resources :friendships do
      member do
        put :deny
        put :accept
      end
      collection do
        get :view
      end
    end

    # my_helpedia.resources :messages, :collection => { :sent => :get, :system => :get }, :member => { :answer => :get, :reply => :post }
    resources :messages do
      member do
        get :answer
        post :reply
      end
      collection do
        get :sent
        get :system
      end
    end
  #  my_helpedia.resources :bookmarks, :collection => { :view => :get }
    resources :bookmarks do
      collection do
        get :view
      end
    end

    resources :feed_events do
      collection do
        get :around
      end
    end

    resources :activities do
      resource :image
      resource :wiki

      member do
        get :description
        get :statistics
        get :edit_part
        get :cancel_edit_part
        get :destroy_confirmation
      end

      resources :activity_event_memberships do
        member do
          get :cancel_edit_part
        end
        collection do
          get :event_list
          get :activity_list
        end
      end

      resources :activity_sponsors do
        member do
          get :cancel_edit_part
        end
      end

      resources :activity_memberships do
        member do
          put :activate
        end
      end

      resource :blog

      resources :blog_posts do
        member do
          put :publish
          put :unpublish
        end
      end

      resources :blog_post_contents do
        collection do
          get :chose
        end
      end

      resources :comments do
        member do
          put :hide
          put :unhide
        end
      end

    end

    resources :organisations do
      member do
        get :edit_part
        get :cancel_edit_part
        get :destroy_confirmation
      end

      resource :address do
        member do
          get :edit_part
          get :cancel_edit_part
        end
      end

      resource :blog

      resources :blog_posts do
        member do
          put :publish
          put :unpublish
        end
      end

      resources :blog_post_contents do
        collection do
          get :chose
        end
      end

      resources :comments do
        member do
          put :hide
          put :unhide
        end
      end

      resources :activity_memberships do
        member do
          put :activate
        end
      end

    end

    resources :locations do

      member do
        get :edit_part
        get :cancel_edit_part
        get :destroy_confirmation
      end

      resources :activity_memberships do
        member do
          put :activate
        end
      end

      resources :comments do
        member do
          put :hide
          put :unhide
        end
      end

    end

    resources :events do
      member do
        get :edit_part
        get :cancel_edit_part
        get :destroy_confirmation
      end
      resources :activity_memberships do
        member do
          get :cancel_edit_part
        end
        collection do
          get :event_list
          get :activity_list
        end
      end
    end

  end # Namespace my_helpedia

  resource :search do
    member do
      get :change_view
    end
  end

  # Activities
  resources :activities do

    resources :commendations
    resources :bookmarks
    resources :activity_memberships
    resources :comments

    member do
      get :description
    end

    collection do
      get :for_day
    end

    resource :feedback
    resource :blog

    resources :blog_posts do
      resources :comments
    end

    resources :petition_users do
      collection do
        get :activities
      end
    end

    resources :events do
      collection do
        get :map
        get :iframe_map
      end
    end

  end

  # Events
  resources :events do

    resources :activities
    resources :bookmarks
    resources :commendations
    resources :comments

    resource :feedback

    collection do
      get :for_day
    end
  end

  # Organisations
  resources :organisations do

    resources :activities
    resources :locations
    resources :messages
    resources :bookmarks
    resources :events
    resources :activity_memberships

    resource :blog
    resource :feedback
    resource :rss

    collection do
      get :registered
    end

    member do
      get :facts
      get :about
      get :bounce
    end

    resource :blog

    resources :blog_posts do
      resources :comments
    end

  end

  resources :locations do

    resource :feedback
    resources :bookmarks
    resources :commendations
    resources :activities
    resources :events
    resources :activity_memberships
    resources :comments

    member do
      get :description
    end

  end

  # Contact Form
  #map.contact_person '/request/contact', :controller => 'requests', :action => 'contact'
  #map.done_request '/request/done', :controller => 'requests', :action => 'done'
  match '/requests/contact' => 'requests#new', :as => :contact_person
  match '/requests/done' => 'requests#done', :as => :done_request
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
