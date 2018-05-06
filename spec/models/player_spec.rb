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

require 'rails_helper'

describe Player, type: :model do

  it { is_expected.to have_many(:teams).through(:team_players) }
  it { is_expected.to have_many(:streaks).through(:streak_players) }
  it { is_expected.to have_many(:habits) }

  it { is_expected.to validate_presence_of(:user_name) }
  it { is_expected.to validate_presence_of(:uuid) }

  it { is_expected.to validate_uniqueness_of(:uuid) }
  it { is_expected.to validate_uniqueness_of(:user_name) }
end
