class StreakResource < ApplicationResource
  type :streaks
  model Streak

  has_and_belongs_to_many :players,
    scope: -> { Player.all  },
    resource: PlayerResource,
    foreign_key: { streak_players: :tag_id  }
end
