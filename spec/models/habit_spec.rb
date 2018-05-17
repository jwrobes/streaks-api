# == Schema Information
#
# Table name: habits
#
#  id           :bigint(8)        not null, primary key
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  player_id    :integer
#  streak_id    :integer
#
# Indexes
#
#  index_habits_on_streak_id_and_player_id  (streak_id,player_id)
#

require 'rails_helper'

RSpec.describe Habit, type: :model do
  it { is_expected.to belong_to(:player) }
  it { is_expected.to belong_to(:streak) }
end
