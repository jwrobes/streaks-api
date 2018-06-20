class OpenStreaksController < JsonapiApplicationController
  include Concerns::PlayerSecured
  jsonapi resource: CurrentPlayer::StreakResource
  strong_resource :streak do
    has_many :players
  end

  before_action :apply_strong_params, only: [:create, :update]

  def index
    if params[:without_user]
    open_streaks = Streak.where.not(id: current_player.streaks.map(&:id))
    else
      open_streaks = Streak.open
    end

    render_jsonapi(open_streaks)
  end

  def create
    streak, success = jsonapi_create.to_a

    if success
      render_jsonapi(streak, scope: false)
    else
      render_errors_for(streak)
    end
  end

  def update
    streak, success = jsonapi_update.to_a

    if success
      render_jsonapi(streak, scope: false)
    else
      render_errors_for(streak)
    end
  end

  def player_added(streak, old_player_count, new_player_count, player)
    if new_player_count == Streak::MIN_PLAYERS
      team_uuid = streak.players.map(&:id).sort.join
      team = Team.find_or_create_by(uuid: team_uuid)
      streak.update!(team: team)
      streak.activate!
    end
  end
end
