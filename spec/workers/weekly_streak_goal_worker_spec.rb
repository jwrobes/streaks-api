require "rails_helper"

describe WeeklyStreakGoalWorker, sidekiq: :inline  do

  subject { described_class.new.perform }


  context "when it runs on Sunday 12am" do
    let(:sunday_1205_am_july_15_pst) { Time.zone.local(2018, 7, 15, 7, 5, 0)  }
    let(:sunday_july_15th) { Date.new(2018, 7, 15) }
    let(:saturday_july_21) { Date.new(2018, 7, 21) }
    let(:last_sunday) { sunday_july_15th - 7.days }
    let(:yesterday_saturday) {saturday_july_21 - 7.days }

    before do
      Timecop.freeze(sunday_1205_am_july_15_pst)
      completion_percent = 0.77
      allow(HabitCompletionPercent).to receive(:between).with({
        start_date: last_sunday,
        end_date: yesterday_saturday
      }).and_return(completion_percent)
    end

    it "adds a  new weekly goal" do
      completion_percent = 0.77
      expect(HabitCompletionPercent).to receive(:between).with({
        start_date: last_sunday,
        end_date: yesterday_saturday
      }).and_return(completion_percent)

      expect { subject }.to change { WeeklyStreakGoal.count }.by(1)
      expect(WeeklyStreakGoal.last.completion_percent).to eq(completion_percent)
    end

    it "adds a new weekly with correct start date" do
      subject
      expect(WeeklyStreakGoal.last.start_date).to eq(sunday_july_15th)
    end

    it "adds a new weekly with correct end date" do
      subject
      expect(WeeklyStreakGoal.last.end_date).to eq(saturday_july_21)
    end
  end
end
