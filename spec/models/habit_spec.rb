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
describe Habit, type: :model do
  it { is_expected.to belong_to(:player) }
  it { is_expected.to belong_to(:streak) }

  describe "validate not over max habits per day" do
    it "is valid when the habit is below the number of max habits per day" do
      streak = create(:streak, :active, max_habits_per_day: 2)
      streak_player = streak.players.last
      first_habit_for_day = create(:habit, player: streak_player, streak: streak)

      second_habit_for_day = create(:habit, player: streak_player, streak: streak)
      expect(second_habit_for_day).to be_valid
    end
    it "is invalid when there habit is above the number of max habits per day" do
      streak = create(:streak, :active, max_habits_per_day: 1)
      streak_player = streak.players.last
      first_habit_for_day = create(:habit, player: streak_player, streak: streak)

      second_habit_for_day = build(:habit, player: streak_player, streak: streak)
      expect(second_habit_for_day).not_to be_valid
    end
    it "is valid when it already created and under the number of max habits for the day" do
      streak = create(:streak, :active, max_habits_per_day: 1)
      streak_player = streak.players.last
      first_habit_for_day = create(:habit, player: streak_player, streak: streak)

      expect(first_habit_for_day).to be_valid
    end
  end

  describe ".scopes" do
    describe ".current_week" do
      context "on a tuesday" do
       let(:tuesday_july_3_at_noon) { Time.zone.local(2018, 7, 3, 12, 0, 0) }
       let(:sunday_june_24th_beginning_of_day) { Time.zone.local(2018, 6, 24, 0, 0, 0) }
        before do
          Timecop.freeze(tuesday_july_3_at_noon)
        end
        after do
          Timecop.return
        end
        it "returns only habits completed after start of streak week" do
          streak = create(:streak, :active, activated_at: sunday_june_24th_beginning_of_day )
          streak_player = streak.players.first
          habit_from_prior_week = create(:habit, {
            streak: streak,
            player: streak_player,
            completed_at: Time.zone.now - 1.week
          })
          habit_from_today = create(:habit, {
            streak: streak,
            player: streak_player,
            completed_at: Time.zone.now
          })

          expect(described_class.current_week.to_a).to match_array([habit_from_today])
        end
      end
    end
  end
end
