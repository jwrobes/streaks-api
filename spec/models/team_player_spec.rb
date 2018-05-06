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

require 'rails_helper'

describe TeamPlayer, type: :model do
  it { is_expected.to belong_to(:team) }
  it { is_expected.to belong_to(:player) }
  it { is_expected.to validate_presence_of(:player) }
  it { is_expected.to validate_presence_of(:team) }
  it { is_expected.to validate_uniqueness_of(:player_id).scoped_to(:team_id) }
end
