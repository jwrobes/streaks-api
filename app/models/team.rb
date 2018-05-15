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

class Team < ApplicationRecord
  has_many :team_players
  has_many :players, through: :team_players
  has_many :streaks

  # validate :only_one_active_streak_for_team

  private

  def only_one_active_streak_for_team
    if streaks.active.count == 1
      errors.add(:streaks, "Team can have only one active streak at a time")
    end
  end
end
