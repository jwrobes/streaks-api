# == Schema Information
#
# Table name: players
#
#  id         :bigint(8)        not null, primary key
#  timezone   :string
#  user_name  :string
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_players_on_user_name  (user_name) UNIQUE
#  index_players_on_uuid       (uuid) UNIQUE
#

FactoryBot.define do
  factory :player do
    sequence(:user_name) { |n| "user#{n}" }
    sequence(:uuid) { |n| "user_uuid#{n}" }
  end
end
