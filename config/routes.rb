require 'resque/server'

Rails.application.routes.draw do

  mount Resque::Server.new, at: "/resque"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#index'

  get 'search' => 'search#index'

  get 'users' => 'users#index'
  get 'users/find_by_email' => 'users#show'
  get 'users/attributes_from_ldap/:unity_id' => 'users#attributes_from_ldap'
  get 'users/attributes_from_ldap/' => 'users#attributes_from_ldap'

  get 'users/:id' => 'users#show', id: /\d+/

  post 'users' => 'users#create'

  put  'users/:id' => 'users#update', id: /\d+/

  delete  'users/:id' => 'users#destroy', id: /\d+/


  get 'users/:id/send_password_reset_link' =>'users#send_password_reset_link'


  devise_for :users, controllers: {
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    unlocks: 'users/unlocks'
  }



  get 'current_user' => 'utility#user_data'

  get 'archivesspace_redirect(/*archivesspace_path)' => 'utility#archivesspace_redirect'
  get 'archivesspace_resolver(/*archivesspace_uri)' => 'utility#archivesspace_resolver'

  get 'aspace_get' => 'utility#aspace_get'

  get 'catalog_get' => 'utility#catalog_get'

  get 'user_typeahead' => 'utility#user_typeahead'
  get 'user_typeahead/:q' => 'utility#user_typeahead'


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  get 'items/pending_transfers' => 'items#pending_transfers'
  get 'items/transfer_list' => 'items#transfer_list'
  get 'items/returns_in_transit' => 'items#returns_in_transit'
  get 'items/digital_object_requests' => 'items#digital_object_requests'
  get 'items/returns_list' => 'items#returns_list'
  get 'items/items_in_transit_for_use' => 'items#items_in_transit_for_use'
  get 'items/items_in_transit_for_use_list' => 'items#items_in_transit_for_use_list'
  put 'items/:id/obsolete' => 'items#obsolete'
  put 'items/:id/change_active_order' => 'items#change_active_order'
  get 'items/:id/update_from_source' => 'items#update_from_source'


  get 'orders/course_reserves' => 'orders#course_reserves'

  get 'orders/:id/call_slip' => 'orders#call_slip'
  get 'orders/:id/history' => 'orders#history'
  put 'orders/:id/update_state' => 'orders#update_state'
  put 'orders/:id/deactivate_item' => 'orders#deactivate_item'
  put 'orders/:id/activate_item' => 'orders#activate_item'
  put 'orders/:id/:event' => 'orders#update_state'

  post 'orders/:id/items' => 'orders#add_associations'
  post 'orders/:id/users' => 'orders#add_associations'
  post 'orders/:id/assignees' => 'orders#add_associations'
  post 'orders/:id/notes' => 'orders#add_associations'
  post 'orders/:id/associations' => 'orders#add_associations'

  delete 'orders/:id/items' => 'orders#delete_associations'
  delete 'orders/:id/users' => 'orders#delete_associations'
  delete 'orders/:id/assignees' => 'orders#delete_associations'
  delete 'orders/:id/notes' => 'orders#delete_associations'
  delete 'orders/:id/associations' => 'orders#delete_associations'

  put 'items/:id/check_in' => 'items#check_in'
  get 'items/:id/history' => 'items#history'
  put 'items/:id/check_out' => 'items#check_out'
  put 'items/:id/receive_at_temporary_location' => 'items#receive_at_temporary_location'
  put 'items/:id/:event' => 'items#update_state'

  post 'items/create_from_archivesspace' => 'items#create_from_archivesspace'
  post 'items/create_from_catalog' => 'items#create_from_catalog'

  resources :requests, controller: 'orders'

  put 'enumeration_values/merge' => 'enumeration_values#merge'
  post 'enumeration_values/update_order' => 'enumeration_values#update_order'

  post 'user_roles/update_levels' => 'user_roles#update_levels'
  put 'user_roles/merge' => 'user_roles#merge'

  resources :orders, :locations, :items, :enumeration_values, :user_roles

  get 'circa_locations' => 'utility#circa_locations'
  get 'states_events' => 'utility#states_events'
  get 'local_values' => 'utility#local_values'
  get 'options' => 'utility#options'
  get 'controlled_values' => 'utility#controlled_values'

  get "reports/item_requests_per_resource" => 'reports/item_requests_per_resource'
  get "reports/item_requests_per_location" => 'reports/item_requests_per_location'
  get "reports/item_transfers_per_location" => 'reports/item_transfers_per_location'

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
