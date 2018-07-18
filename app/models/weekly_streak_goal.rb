# == Schema Information
#
# Table name: weekly_streak_goals
#
#  id                 :bigint(8)        not null, primary key
#  completion_percent :decimal(, )
#  end_date           :date
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class WeeklyStreakGoal < ApplicationRecord
  validates :start_date, :end_date, :completion_percent, presence: true

  DEFAULT_COMPLETION_PERCENT = 0.60

  def self.current(current_date=Time.zone.today)
    find_by("start_date <= ? and end_date >= ?", current_date, current_date)
  end
end
