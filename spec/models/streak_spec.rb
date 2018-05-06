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

require 'rails_helper'

describe Streak, type: :model do

  it { is_expected.to belong_to(:team) }
  it { is_expected.to have_many(:players).through(:streak_players) }
  it { is_expected.to have_many(:habits) }

  it { is_expected.to validate_presence_of(:status) }
end
