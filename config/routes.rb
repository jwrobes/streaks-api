Rails.application.routes.draw do
  scope path: '/streaks_api' do
    scope path: '/v1' do
      resources :open_streaks, only: [:index, :create, :update]
      resource :current_player, only: [:show]
      scope module: 'current_player', path: 'current_player' do
        resources :active_streaks, only: [:index, :update, :show]
        resources :open_streaks, only: [:index, :create, :update, :destroy]
      end
    end
  end
  resources :messages
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
