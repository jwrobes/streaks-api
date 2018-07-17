# == Schema Information
#
# Table name: weekly_streak_goals
#
#  id                 :bigint(8)        not null, primary key
#  completion_percent :decimal(, )
#  end_date           :date
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe WeeklyStreakGoal, type: :model do
  def set_up_current_and_last_week_goals
    sunday_july_15th_1201am = Time.zone.local(2018, 7, 15, 0, 1, 0)
    sunday_july_15th =  Date.new(2018, 7, 15)
    saturday_july_21st = Date.new(2018, 7, 21)

    current_week_goal = create(:weekly_streak_goal, {
      completion_percent: 0.5,
      start_date: sunday_july_15th,
      end_date: saturday_july_21st
    })
    last_week_goal = create(:weekly_streak_goal, {
      completion_percent: 0.5,
      start_date: sunday_july_15th - 7.days,
      end_date: saturday_july_21st - 7.days
    })
    [current_week_goal, last_week_goal]
  end
  describe ".current" do
    context "when the current time in in the Sunday 12:01am" do
      let(:sunday_july_15th_1201am) { Time.zone.local(2018, 7, 15, 0, 2, 0) }
      let(:sunday_july_15th) { Date.new(2018, 7, 15) }
      let(:saturday_july_21st) { Date.new(2018, 7, 21) }

      before do
        Timecop.freeze(sunday_july_15th_1201am)
      end
      after do
        Timecop.return
      end
      it "returns the only the streak goal for the current week" do
        current_week_goal, last_week_goal = set_up_current_and_last_week_goals

        expect(described_class.current).to eq(current_week_goal)
      end
    end

    context "when the current time is Saturday 11:59pm" do
      before do
        Timecop.freeze(Time.zone.local(2018, 7, 21, 23, 59, 0))
      end
      after do
        Timecop.return
      end

      it "returns the only the streak goal for the current week" do
        current_week_goal, last_week_goal = set_up_current_and_last_week_goals

        expect(described_class.current).to eq(current_week_goal)
      end
    end
  end
end
