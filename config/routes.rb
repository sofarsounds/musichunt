Rails.application.routes.draw do
  mount ActiveApi::Engine => '/aappii'

  root to: 'items#index'
  resources :user_sessions, only: [:new, :create, :destroy]
  resources :users, except: [:index]
  resources :items, except: [:destroy] do
    resources :item_comments
    member do
      post :toggle
      post :vote, to: 'user_item_votes#create'
      delete :vote, to: 'user_item_votes#destroy'
    end
  end


  get 'login' => 'user_sessions#new', as: :login
  post 'logout' => 'user_sessions#destroy', as: :logout
end