class StreakResource < ApplicationResource
  type :streaks
  model Streak

  def update(update_params)
    instance = model.find(update_params.delete(:id))
    instance.add_listener(context)
    instance.update_attributes(update_params)
    instance
  end

  has_and_belongs_to_many :players,
    scope: -> { Player.all },
    resource: PlayerResource,
    foreign_key: { streak_players: :player_id  }

  has_many :habits,
    resource: HabitResource,
    foreign_key: :streak_id,
    scope: -> { Habit.all  }
end
