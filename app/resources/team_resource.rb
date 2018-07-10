class TeamResource < ApplicationResource
  type :teams
  model Team

  has_many :streaks,
    scope: -> { Streak.all  },
    resource: StreakResource,
    foreign_key: :streak_id

  has_many :team_players,
    scope: -> { TeamPlayer.all },
    resource: TeamPlayerResource,
    foreign_key: :team_id
end
