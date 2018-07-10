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

require 'rails_helper'

describe Team, type: :model do
  it { is_expected.to have_many(:players).through(:team_players) }
  it { is_expected.to have_many(:streaks) }

  describe "#add_players" do
    it "adds players with default colors" do
      active_streak = create(:streak, :active)
      team = active_streak.team
      team.add_players(active_streak.players)
      expect(team.team_players.count).to eq(active_streak.players.count)
      expect(team.team_players.map(&:color)).to match_array(Team::DEFAULT_COLORS)
    end
  end
end
