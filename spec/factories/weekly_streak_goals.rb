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

FactoryBot.define do
  factory :weekly_streak_goal do
    completion_percent 0.656
    trait :current do
      start_date Date.today.beginning_of_week(:sunday)
      end_date { start_date + 6.days }
    end
  end
end
