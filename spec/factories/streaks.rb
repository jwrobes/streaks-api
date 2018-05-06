# == Schema Information
#
# Table name: streaks
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  ended_at        :datetime
#  habits_per_week :integer
#  started_at      :datetime
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
    started_at "2018-05-05 22:08:47"
    ended_at "2018-05-05 22:08:47"
    team_id 1
    status "MyString"
  end
end
