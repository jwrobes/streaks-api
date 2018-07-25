require 'rails_helper'

describe HabitCompletionPercent, type: :model do

  let(:sunday_july_15) { Date.new(2018, 7, 15) }
  let(:saturday_july_21) { Date.new(2018, 7, 21) }
  describe ".between" do
    context "with two active streaks in between the start and end date" do
      it "returns mean completion pct for players in active streaks between start and end date" do
        start_date = sunday_july_15
        end_date = saturday_july_21
        time_before_start_date = (start_date - 4.hours)
        time_after_start_date = (start_date + 5.days + 10.hours)
        active_streak_full_week = create(:streak, :active,{
          habits_per_week: 7,
        })
        active_streak_full_week.update(activated_at: time_before_start_date)

        active_streak_partial_week = create(:streak, :active, {
          habits_per_week: 5,
        })
        active_streak_partial_week.update(activated_at: time_after_start_date)

        # Half of players complete 100% of the full week habits
        (start_date..end_date).each do |date|
          active_streak_full_week.players.each_with_index do |player, index|
            if index % 2 == 0
              create(:habit, {
                streak: active_streak_full_week,
                player: player,
                completed_at: date.to_time + 5.hours,
                completed_date: date
              })
            end
          end
        end
        # All the players complete 100% of the habits for the short week
          active_streak_partial_week.players.each_with_index do |player, index|
              create(:habit, {
                streak: active_streak_partial_week,
                player: player,
                completed_at: end_date - 1.day + 5.hours,
                completed_date: (end_date - 1.day).to_date
              })
          end
          # completions for full streak = 3 players * 7 habits = 21 habits / 42 possible habits
          # completion for partial streak = 6 players * 1 habits = 6 / 6 possible habits
          # total completion percent = (21 + 6) / (42 + 6)
          expected_total_completion_percent = (27.0/48.0)  # 0.5625

          expect(described_class.between({
            start_date: start_date,
            end_date: end_date
          })).to eq(expected_total_completion_percent)
      end
    end
  end
end
