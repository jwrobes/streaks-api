# == Schema Information
#
# Table name: team_players
#
#  id         :bigint(8)        not null, primary key
#  color      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player_id  :integer
#  team_id    :integer
#
# Indexes
#
#  index_team_players_on_team_id_and_player_id  (team_id,player_id)
#

class TeamPlayer < ApplicationRecord
end
