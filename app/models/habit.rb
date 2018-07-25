# == Schema Information
#
# Table name: habits
#
#  id             :bigint(8)        not null, primary key
#  completed_at   :datetime
#  completed_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  player_id      :integer
#  streak_id      :integer
#
# Indexes
#
#  index_habits_on_completed_date           (completed_date)
#  index_habits_on_streak_id_and_player_id  (streak_id,player_id)
#

class Habit < ApplicationRecord
  belongs_to :player
  belongs_to :streak
  validate :is_not_over_max_habits_per_day_for_streak

  scope :current_week, -> { where('completed_at > ?', DateTime.now.beginning_of_week(:sunday)) }
  scope :between_dates, -> (date_range) { where(completed_date: date_range) }

  private

  def is_not_over_max_habits_per_day_for_streak
    count_of_habits_for_player_today = streak.habits.where(player_id: player.id).where('completed_at between ? AND ?', completed_at.beginning_of_day, completed_at.end_of_day)
    if id.present?
      count_of_habits_for_player_today = count_of_habits_for_player_today.where.not(id: id)
    end
    if count_of_habits_for_player_today.count >= streak.max_habits_per_day
      errors.add(:streak, "Can't add more than max habit per day for this streak")
    end
  end
end
