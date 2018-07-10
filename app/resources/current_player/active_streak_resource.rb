module CurrentPlayer
  class ActiveStreakResource < ApplicationResource
    type :streaks
    model Streak

    def update(update_params)
      instance = model.find(update_params.delete(:id))
      instance.add_listener(context)
      instance.update_attributes(update_params)
      instance.habits << Habit.new(player: current_player, completed_at: Time.zone.now)
      instance.save
      instance
    end

    has_and_belongs_to_many :players,
      scope: -> { Player.all },
      resource: PlayerResource,
      foreign_key: { streak_players: :streak_id }

    has_many :habits,
      scope: -> { Habit.all },
      resource: HabitResource,
      foreign_key: :streak_id

    private

    def current_player
      context.current_player
    end
  end
end
