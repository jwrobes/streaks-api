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

FactoryBot.define do
  factory :streak_player do
    streak_id 1
    player_id 1
  end
end
