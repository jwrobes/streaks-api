# == Schema Information
#
# Table name: players
#
#  id         :bigint(8)        not null, primary key
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

class Player < ApplicationRecord
  has_many :team_players
  has_many :teams, through: :team_players
  has_many :streak_players
  has_many :streaks, through: :streak_players
  has_many :habits

  validates :user_name, :uuid, presence: true
  validates :uuid, :user_name, uniqueness: true

end
