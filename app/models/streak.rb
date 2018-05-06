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

class Streak < ApplicationRecord
  belongs_to :team, optional: true
  has_many :streak_players
  has_many :habits
  has_many :players, through: :streak_players

  validates :status, presence: true
 
end
