class StreakResource < ApplicationResource
  type :streaks
  model Streak

  def update(update_params)
    instance = model.find(update_params.delete(:id))
    instance.add_listener(context)
    instance.update_attributes(update_params)
    instance
  end

  def create(create_params)
    m = model.new(create_params)
    m.save
    m
  end

  has_and_belongs_to_many :players,
    scope: -> { Player.all },
    resource: ::PlayerResource,
    foreign_key: { streak_players: :streak_id }

  has_many :habits,
    resource: HabitResource,
    foreign_key: :streak_id,
    scope: -> { Habit.all  }

  allow_sideload :teams, resource: TeamResource do
    scope do |streaks|
      Team.where(id: streaks.map(&:team_id))
    end
    assign do |streaks, teams|
      streaks.each do |streak|
        streak.team = teams.select { |t| t.id == streak.team_id }.first
      end
    end
  end

  allow_sideload :team_players, resource: TeamPlayerResource do
    scope do |streaks|
      TeamPlayer.where(team_id: streaks.map(&:team_id))
    end
    assign do |streaks, team_players|
      streaks.each do |streak|
        streak.team_players = team_players.select { |tp| tp.team_id == streak.team_id }
      end
      end
    end


  private

  def current_player
    context.current_player
  end
end
