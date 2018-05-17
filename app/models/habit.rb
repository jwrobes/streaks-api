# == Schema Information
#
# Table name: habits
#
#  id           :bigint(8)        not null, primary key
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  player_id    :integer
#  streak_id    :integer
#
# Indexes
#
#  index_habits_on_streak_id_and_player_id  (streak_id,player_id)
#

class Habit < ApplicationRecord
  belongs_to :player
  belongs_to :streak
  validate :is_not_over_max_habits_per_day_for_streak

  private

  def is_not_over_max_habits_per_day_for_streak
    count_of_habits_for_player_today = streak.habits.where(player_id: player.id).where('completed_at between ? AND ?', completed_at.beginning_of_day, completed_at.end_of_day).count 
    if count_of_habits_for_player_today >= streak.max_habits_per_day
      errors.add(:streak, "Can't add more than max habit per day for this streak")
    end
  end
end
