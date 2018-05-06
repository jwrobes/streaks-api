# == Schema Information
#
# Table name: teams
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  it { is_expected.to have_many(:players).through(:team_players) }
end
