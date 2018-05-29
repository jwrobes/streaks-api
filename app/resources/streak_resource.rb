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
    m.players << current_player
    m.save
    m
  end

  has_and_belongs_to_many :players,
    scope: -> { Player.all },
    resource: PlayerResource,
    foreign_key: { streak_players: :streak_id }

  has_many :habits,
    resource: HabitResource,
    foreign_key: :streak_id,
    scope: -> { Habit.all  }

  private

  def current_player
    context.current_player
  end
end
