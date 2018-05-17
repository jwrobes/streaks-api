require "rails_helper"

describe CurrentPlayer::ActiveStreaksController, type: :controller do

  describe "GET #index" do
    it "returns a success response with authenticated token" do
      # login as user with active streak and with one open streak
      active_streak_with_players = create(:streak, :active, :with_players, players_count: 6)
      current_player = active_streak_with_players.players.last
      open_streak_with_players = create(:streak, :open, :with_players, players_count: 4)
      open_streak_with_players.players << current_player
      # create another active streak without the current player
      active_streak_without_current_player = create(:streak, :active, :with_players, {
        players_count: 6
      })
      login_as(current_player)

      get :index, params: {}, format: :json
      expect(response).to be_success
    end

    it "returns only active streak that current player is part of" do
      # login as user with active streak and with one open streak
      active_streak_with_current_player = create(:streak, :active, :with_players, players_count: 6)
      current_player = active_streak_with_current_player.players.last

      open_streak_with_current_player = create(:streak, :open, :with_players, players_count: 4)
      open_streak_with_current_player.players << current_player
      # create another active streak without the current player
      active_streak_without_current_player = create(:streak, :active, :with_players, {
        players_count: 6
      })
      login_as(current_player)

      get :index, params: {}, format: :json

      data = JSON.parse(response.body)["data"]
      streak_ids = data.map {|r| r["id"]}
      expect(streak_ids).not_to include(open_streak_with_current_player.id.to_s)
      expect(streak_ids).not_to include(active_streak_without_current_player.id.to_s)
      expect(streak_ids).to include(active_streak_with_current_player.id.to_s)
    end
  end

  describe "PUT #update" do
    it "reseponds successfully" do
      # mock authenticated token
      active_streak = create(:streak, :active, :with_players, {
        players_count: 6
      })
      current_player = active_streak.players.last
      login_as(current_player)

      patch :update, params: add_habit_to_active_streak_update_params(active_streak, current_player), format: :json
      expect(response).to be_success
    end

    it "creates a new habit for this streak for current player" do
      # mock authenticated token
      active_streak = create(:streak, :active, :with_players, {
        players_count: 6
      })
      current_player = active_streak.players.last
      login_as(current_player)

      expect do
        patch :update, params: add_habit_to_active_streak_update_params(active_streak, current_player), format: :json
      end.
      to change { Habit.count }.from(0).to(1)
      expect(current_player.reload.habits.count).to eq(1)
      expect(active_streak.habits.count).to eq(1)

    end

    context "when a current player adds over the daily limit for the streak" do
      it "does not create a new habit for this streak for current player" do
        # mock authenticated token
        streak = create(:streak, :active, max_habits_per_day: 1)
        current_player = streak.players.first
        second_habit_completed_time = Time.zone.now

        login_as(current_player)

        first_habit_on_day = create(:habit, streak: streak, player: current_player, completed_at: second_habit_completed_time - 1.hour)

        expect do
          patch :update, params: add_habit_to_active_streak_update_params(streak, current_player), format: :json
        end.
        not_to change { Habit.count }.from(1)

        expect(response.code).to eq("422")
        expect(current_player.reload.habits.count).to eq(1)
        expect(streak.habits.count).to eq(1)
      end
    end
  end

  describe "#GET show" do
    context "when participant is a streak player for streak" do
      it "returns active streak for participant" do
        active_streak = create(:streak, :active, :with_players, {
          players_count: 6
        })
        current_player = active_streak.players.last
        login_as(current_player)

        get :show, params: { id: active_streak.id  }, format: :json
        expect(response).to be_success
      end
    end

    context "when participant is not a player in the streak" do
      it "returns authorized error" do
        active_streak = create(:streak, :active, :with_players, {
          players_count: 6
        })
        current_player = create(:player)
        login_as(current_player)

        get :show, params: { id: active_streak.id  }, format: :json
        expect(response.code).to eq("404")
      end
    end
  end

  def add_habit_to_active_streak_update_params(active_streak, player)
    {
      id: active_streak.id,
      "data": {
        "type": "streaks",
        "id": "#{active_streak.id}",
        "relationships": {
          "habits": {
            "data": [
              { :"temp-id" => "abc123", type: "habits", method: "create" }
            ]
          }
        }
      },
      included: [
        {
          type: "habits",
          :"temp-id" => "abc123",
          attributes: {
            player_id: "#{player.id}",
            streak_id: "#{active_streak.id}",
            completed_at: Time.zone.now.to_s
          }
        }
      ]
    }
  end
end
