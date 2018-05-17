# == Schema Information
#
# Table name: teams
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#  index_teams_on_uuid  (uuid)
#

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "TeamName#{n}" }
    sequence(:uuid) { |n| "team_uuid#{n}" }
  end

  trait :with_team_players do
    transient do
      team_players_count 6
    end
    after(:create) do |team, options|
      create_list :player, (options.team_players_count), teams: [team]
    end
    after(:create) do |team, options|
      team.update!(uuid: team.players.map(&:id).sort.join)
    end
  end
end
