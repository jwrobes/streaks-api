# == Schema Information
#
# Table name: streaks
#
#  id              :bigint(8)        not null, primary key
#  activated_at    :datetime
#  completed_at    :datetime
#  description     :text
#  ended_at        :datetime
#  habits_per_week :integer
#  status          :string           default("open"), not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :integer
#

FactoryBot.define do
  factory :streak do
    title "MyString"
    description "MyText"
    habits_per_week 1
    status "open"
  end

  trait :open do
    status "open"
  end

  trait :active do
    team
    status "active"
  end
end
