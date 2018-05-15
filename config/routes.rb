Rails.application.routes.draw do
  scope path: '/streaks_api' do
    scope path: '/v1' do
      # your routes go here
    end
  end
  resources :messages
  resources :open_streaks, only: [:index, :create, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
