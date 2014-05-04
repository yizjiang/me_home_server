SpotCard::Application.routes.draw do
  resources :post_cards
  root to: 'application#index'
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  #devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
end
