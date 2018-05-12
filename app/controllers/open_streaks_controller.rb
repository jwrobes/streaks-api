class OpenStreaksController < ApplicationController
  include Concerns::PlayerSecured
  jsonapi resource: StreakResource
  strong_resource :streak do
    has_many :players
  end

  before_action :apply_strong_params, only: [:create, :update]

  def index
    @open_streaks = Streak.open.all
    render_jsonapi(@open_streaks)
  end

  def create
    streak, success = jsonapi_create.to_a

    if success
      render_jsonapi(streak, scope: false)
    else
      render_errors_for(post)
    end
  end
end
