require 'sidekiq/web'

MeHome::Application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"

  root to: 'application#index'
  resources :home
  get 'homes/show_all', to: 'home#show_all'
  resources :region
  resources :school
  resources :article, only: [:index, :show]

  resources :user do
    member do
      get 'homes', to: 'user#all_favorite_hoems'
    end
  end

  resources :session
  resources :question

  resources :commercial do
    resources :property
  end

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"},
             controllers: {omniauth_callbacks: "omniauth_callbacks"}
  devise_for :users do get '/users/logout' => 'devise/sessions#destroy' end
  devise_for :users do get '/users/sign_out' => 'devise/sessions#destroy' end
  devise_for :users do post '/users/sign_in' => 'login#create' end

  #post 'users/sign_in', to: 'login#create'

  post 'qr_code', to: 'user#qr_code'
  get 'check_login', to: 'user#check_login'

  get 'home/search/listing', to: 'home#search_by_listing'
  get 'home/search/price', to: 'home#search_by_price'

  get 'all_city', to: 'region#all_city'
  get 'all_schools', to: 'school#all_schools'
  get 'bay_area_cities', to: 'region#bay_area_cities'

  get 'wechat_login', to: 'application#wechat_login'
  get 'agent/set_search', to: 'agent#set_search'
  #get 'agent/customers', to: 'agent#all_customer'
  post 'agent/save_customer_search', to: 'agent#save_customer_search'
  post 'agent/add_customer_search', to: 'agent#add_customer_search'

  get 'agent/:name', to: 'agent#index'
  get 'agents', to: 'agent#active_agents'
  get 'agent/:id/meejia_image', to: 'agent#meejia_image'
  get 'agent/:id/home_list', to: 'agent#home_list'
  get 'wechat/user/:id/search', to: 'user#wechat_search'

  get 'agent/:id/show', to: 'agent#show'
  post 'agent/:id/edit', to: 'agent#edit'

  post 'agent/:id/generate_home_qr_code', to: 'agent#generate_home_qr_code'

  get 'agent/:uid/customers', to: 'agent#all_customer'
  get 'agent/:uid/requests', to: 'agent#all_request'

  post 'agent/save_page_config', to: 'agent#save_page_config'
  post '/agent/upload_qrcode', to: 'agent#upload_qrcode'
  post 'agent/contact_request', to: 'agent#contact_request'
  post 'agent/request_response', to: 'agent#request_response'

  post 'user/save_search', to: 'user#save_search'
  delete 'user/remove_search/:id', to: 'user#remove_search'
  post 'user/submit_question', to: 'user#submit_question'
  post 'user/favorite_home', to: 'user#favorite_home'
  post 'user/unfavorite_home', to: 'user#unfavorite_home'
  post 'user/send_home_card', to: 'user#send_home_card'
  post 'question/post_answer', to: 'question#post_answer'

  get 'dm/wechat', to: 'wechat#auth'
  get 'wechat/callback', to: 'wechat#collect_data'

  post 'dm/wechat', to: 'wechat#message'

  get 'customers', to: 'customer#index'
  post 'customers/connect', to: 'customer#connect'

  get 'metric/home_view_list', to: 'metric#display_all_users'
  get 'metric/user/:id/house_viewed', to: 'metric#display_all_houses'
  post 'user/metric_tracking', to: 'metric#metric_tracking'
  post 'user/metric_tracking_h', to: 'metric#metric_tracking_h'
  get 'metric/house_list', to: 'metric#house_list'

end
