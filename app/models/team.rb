# == Schema Information
#
# Table name: teams
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#  index_teams_on_uuid  (uuid)
#

class Team < ApplicationRecord
  has_many :team_players
  has_many :players, through: :team_players
  has_many :streaks
  DEFAULT_COLORS = [
    "#1abc9c", # turquoise
    "#FC427B", #pink
    "#8e44ad", # purple
    "#e67e22", #carrot
    "#2980b9", #blue
    "#B33771", #fuscia
  ]

  def add_players(players)
    raise StandardError if players.count != 6
    players.each_with_index do |player, i|
      team_players << TeamPlayer.new(player: player, color: DEFAULT_COLORS[i])
    end
  end
end
