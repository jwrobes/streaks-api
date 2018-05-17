module CurrentPlayer
  class ActiveStreaksController < ApplicationController
    # Mark this as a JSONAPI controller, associating with the given resource
    jsonapi resource: StreakResource
    strong_resource :streak do
      has_many :players
    end

    before_action :apply_strong_params, only: [:create, :update]

    # Start with a base scope and pass to render_jsonapi
    def index
      streaks = Streak.active.all
      render_jsonapi(streaks)
    end

    # Call jsonapi_scope directly here so we can get behavior like
    # sparse fieldsets and statistics.
    def show
      scope = jsonapi_scope(Streak.where(id: params[:id]))
      instance = scope.resolve.first
      raise JsonapiCompliable::Errors::RecordNotFound unless instance
      render_jsonapi(instance, scope: false)
    end

    # jsonapi_create will use the configured Resource (and adapter) to persist.
    # This will handle nested relationships as well.
    # On validation errors, render correct error JSON.
    def create
      streak, success = jsonapi_create.to_a

      if success
        render_jsonapi(streak, scope: false)
      else
        render_errors_for(streak)
      end
    end

    # jsonapi_update will use the configured Resource (and adapter) to persist.
    # This will handle nested relationships as well.
    # On validation errors, render correct error JSON.
    def update
      streak, success = jsonapi_update.to_a

      if success
        render_jsonapi(streak, scope: false)
      else
        render_errors_for(streak)
      end
    end

    # Renders 200 OK with empty meta
    # http://jsonapi.org/format/#crud-deleting-responses-200
    def destroy
      streak, success = jsonapi_destroy.to_a

      if success
        render json: { meta: {} }
      else
        render_errors_for(streak)
      end
    end
  end
end
