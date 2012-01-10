Bewegung::Application.routes.draw do

  #match '/kontakt' => 'feedbacks#contact'

  # Feed Events
  resources :feed_events

  # Events
  resources :events

  # Activities
  resources :activities

  # Organisations
  resources :organisations

  # Locations
  resources :locations

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
    collection do
      get 'split'
      get 'registered'
    end
  end

  # Old Helpedia Stuff, to be renamed

  match 'my_helpedia' => 'my_helpedia#index'

  namespace :my_helpedia do
  end

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
