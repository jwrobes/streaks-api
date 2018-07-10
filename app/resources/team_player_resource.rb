class TeamPlayerResource < ApplicationResource
  type :team_players
  model TeamPlayer

  belongs_to :team,
    scope: -> { Team.all  },
    resource: TeamResource,
    foreign_key: :team_id
end
