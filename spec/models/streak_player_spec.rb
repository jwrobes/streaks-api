# == Schema Information
#
# Table name: streak_players
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player_id  :integer
#  streak_id  :integer
#
# Indexes
#
#  index_streak_players_on_streak_id_and_player_id  (streak_id,player_id)
#

require 'rails_helper'

describe StreakPlayer, type: :model do
  it { is_expected.to belong_to(:player) }
  it { is_expected.to belong_to(:streak) }
  it { is_expected.to validate_presence_of(:player) }
  it { is_expected.to validate_presence_of(:streak) }
  it { is_expected.to validate_uniqueness_of(:player_id).scoped_to(:streak_id) }
end
