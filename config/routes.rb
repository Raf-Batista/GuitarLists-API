Rails.application.routes.draw do
  post '/login', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
  post '/session', to: 'sessions#token'
  post '/message', to: 'users#message'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users do
    resources :guitars
  end
  resources :guitars, only: [:index]
end
