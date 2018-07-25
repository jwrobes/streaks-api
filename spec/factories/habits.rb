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

FactoryBot.define do
  factory :habit do
    streak_id 1
    player_id 1
    completed_at Time.zone.now
  end
end
