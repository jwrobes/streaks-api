Rails.application.routes.draw do
  resources :messages
  resources :open_streaks, only: :index
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
