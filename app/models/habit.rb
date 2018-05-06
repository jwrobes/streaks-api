# == Schema Information
#
# Table name: habits
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player_id  :integer
#  streak_id  :integer
#
# Indexes
#
#  index_habits_on_streak_id_and_player_id  (streak_id,player_id)
#

class Habit < ApplicationRecord
  belongs_to :player
  belongs_to :streak
end
