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

  trait :with_players do
    transient do
      players_count 3
    end
    after(:create) do |streak, options|
      create_list :player, (options.players_count), streaks: [streak]
    end
  end

  trait :active do
    transient do
      players_count 6
    end
    after(:create) do |streak, options|
      create_list :player, (options.players_count), streaks: [streak]
    end
    after(:create) do |streak|
      create :team, uuid: streak.players.map(&:id).join, streaks: [streak]
    end
    after(:create, &:activate!)
  end

  trait :completed do
    transient do
      players_count 6
    end
    after(:create) do |streak, options|
      create_list :player, (options.players_count), streaks: [streak]
    end
    after(:create) do |streak|
      create :team, uuid: streak.players.map(&:id).join, streaks: [streak]
    end
    after(:create, &:activate!)
    after(:create, &:complete!)
  end
end
