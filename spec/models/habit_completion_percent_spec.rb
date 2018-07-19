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
        time_after_start_date = (start_date + 5.days + 4.hours)
        active_streak_full_week = create(:streak, :active, {
          activated_at: time_before_start_date
        })
        active_streak_partial_week = create(:streak, :active, {
          activated_at: time_after_start_date
        })
      end
    end
  end
end
