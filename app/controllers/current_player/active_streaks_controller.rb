module CurrentPlayer
  class ActiveStreaksController < ApplicationController
    # Mark this as a JSONAPI controller, associating with the given resource
    include Concerns::PlayerSecured
    jsonapi resource: StreakResource
    strong_resource :streak do
      has_many :players
      has_many :habits
    end

    before_action :apply_strong_params, only: [:update]

    # Start with a base scope and pass to render_jsonapi
    def index
      streaks = current_player.streaks.active
      render_jsonapi(streaks)
    end

    # Call jsonapi_scope directly here so we can get behavior like
    # sparse fieldsets and statistics.
    def show
      scope = jsonapi_scope(Streak.where(id: params[:id]))
      instance = scope.resolve.first
      raise JsonapiCompliable::Errors::RecordNotFound unless instance
      raise Errors::NotAuthorized unless instance.players.include?(current_player)
      render_jsonapi(instance, scope: false)
    end

    def update
      streak, success = jsonapi_update.to_a

      if success
        render_jsonapi(streak, scope: false)
      else
        render_errors_for(streak)
      end
    end
  end
end
