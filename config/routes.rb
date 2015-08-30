MeHome::Application.routes.draw do
  root to: 'application#index'
  resources :home
  resources :region
  resources :school
  resources :user
  resources :session

  post 'user/save_search', to: 'user#save_search'
  post 'user/submit_question', to: 'user#submit_question'
  post 'user/favorite_home', to: 'user#favorite_home'

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"},
             controllers: {omniauth_callbacks: "omniauth_callbacks"}
  devise_for :users do get '/users/logout' => 'devise/sessions#destroy' end
  devise_for :users do get '/users/sign_out' => 'devise/sessions#destroy' end
end
