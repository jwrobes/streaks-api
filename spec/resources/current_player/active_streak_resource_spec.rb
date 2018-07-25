require "rails_helper"

describe CurrentPlayer::ActiveStreakResource do
  subject { described_class.new }
  before do
    # allow(subject).to receive(current_player)
  end

  def setup_active_streak_resource_current_player
    active_streak = create(:streak, :active)
    current_player = active_streak.players.first
    resource = described_class.new
    allow(resource).to receive(:current_player).and_return(current_player)
    [active_streak, resource, current_player]
  end
  describe "#update" do
    it "adds a new habit to the streak" do
      active_streak, resource, current_player = setup_active_streak_resource_current_player
      streak_params = ActionController::Parameters.new(id: active_streak.id.to_s)

      expect do
        resource.update(streak_params)
      end.to change{active_streak.reload.habits.count}.by(1)
    end

    it "creates adds a new habit current player" do
      active_streak, resource, current_player = setup_active_streak_resource_current_player
      streak_params = ActionController::Parameters.new(id: active_streak.id.to_s)

      expect do
        resource.update(streak_params)
      end.to change{current_player.reload.habits.count}.by(1)
    end

    context "when utc time is different than date for curent player" do
      let(:utc_date_july_24_but_los_angeles_date_july_23) do
        Time.utc(2018, 7, 24, 0, 0)
      end
      before do
        Timecop.freeze(utc_date_july_24_but_los_angeles_date_july_23)
      end
      after do
        Timecop.return
      end

      it "sets up habit with completed date in current player timezone" do
        active_streak, resource, current_player = setup_active_streak_resource_current_player
        streak_params = ActionController::Parameters.new(id: active_streak.id.to_s)
        current_player.update(timezone: "America/Los_Angeles")
        resource.update(streak_params)
        new_habit = current_player.habits.last

        expect(new_habit.completed_date).to eq(Date.new(2018, 7, 23))
      end
    end
  end
end
