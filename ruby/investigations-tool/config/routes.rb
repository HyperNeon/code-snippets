Rails.application.routes.draw do

  get 'ticket/index'

  get 'dashboard/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  
  get 'investigation/:id/index' => 'investigation#index', as: :investigation
  get 'investigation/:id/refresh' => 'investigation#refresh', as: :investigation_refresh
  get 'issue/:id/index' =>  'issue#index', as: :issue
  post 'issue/:id/run_query' => 'issue#run_query', as: :issue_query
  get 'utility/index' => 'utility#index', as: :utility
  post 'issue/:id/show_query_details' => 'issue#show_query_details', as: :issue_details
  get 'issue/:id/mark_as_viewed' => 'issue#mark_as_viewed', as: :issue_viewed
  get 'ticket/:ticket' => 'ticket#index', as: :ticket
  get 'ticket' => 'ticket#index', as: :ticket_search
  post 'issue/post_comment' => 'issue#post_comment', as: :post_comment
  get 'search_jira_users' => 'application#search_jira_users', as: :search_jira_users
  post 'issue/assign_ticket' => 'issue#assign_ticket', as: :assign_ticket
  post 'issue/update_status' => 'issue#update_status', as: :update_status
  post 'issue/:id/start_timer' => 'issue#start_timer', as: :start_timer
  post 'issue/:id/post_results_as_comment' => 'issue#post_results_as_comment', as: :post_results_as_comment
  get 'issue/load_comments' => 'issue#load_comments', as: :load_comments
  get 'history/index' => 'history#index', as: :history


  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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

  resources :jira_sessions, only: [:new]
  get 'authorize', to: 'jira_sessions#authorize'
end
