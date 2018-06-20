module CurrentPlayer
  class StreakResource < ApplicationResource
    type :streaks
    model Streak

    def update(update_params)
      instance = model.find(update_params.delete(:id))
      instance.add_listener(context)
      instance.update_attributes(update_params)
      instance.players << current_player
      instance
    end

    def create(create_params)
      m = model.new(create_params)
      m.players << current_player
      m.save
      m
    end

    def destroy(id)
      instance = model.find(id)
      instance.add_listener(context)
      instance.streak_players.find_by_player_id(current_player.id).destroy
      if instance.players.count == 0
        instance.destroy
      end
      instance
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
end
