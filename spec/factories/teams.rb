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
    name "MyString"
    sequence(:uuid) { |n| "team_uuid#{n}" }
  end
end
