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

class StreakPlayer < ApplicationRecord
  belongs_to :player
  belongs_to :streak
  validates_presence_of :player, :streak
  validates :player_id, uniqueness: { scope: :streak_id, message: "can only join a streak once." }
end
