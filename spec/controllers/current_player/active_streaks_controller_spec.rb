require "rails_helper"

describe CurrentPlayer::ActiveStreaksController, type: :controller do

  def setup_active_streak_current_player(with_habit: false)
    active_streak = create(:streak, :active)
    active_streak.team.add_players(active_streak.players)
    current_player = active_streak.players.last
    habit = nil
    if with_habit
      habit = Habit.new(player: current_player, completed_at: Time.zone.now)
      active_streak.habits << habit
    end
    login_as(current_player)
    [active_streak, current_player, habit]
  end

  describe "GET #index" do
    it "returns a success response with authenticated token" do
      setup_active_streak_current_player

      active_streak_without_current_player = create(:streak, :active, :with_players, {
        players_count: 6
      })

      get :index, params: {}, format: :json
      expect(response).to be_success
    end

    it "returns only active streak that current player is part of" do
      active_streak_with_current_player, current_player = setup_active_streak_current_player
      open_streak_with_current_player = create(:streak, :open, :with_players, {
        players_count: 4
      })
      open_streak_with_current_player.players << current_player

      # create another active streak without the current player
      active_streak_without_current_player = create(:streak, :active, :with_players, {
        players_count: 6
      })

      get :index, params: {}, format: :json

      data = JSON.parse(response.body)["data"]
      streak_ids = data.map {|r| r["id"]}
      expect(streak_ids).not_to include(open_streak_with_current_player.id.to_s)
      expect(streak_ids).not_to include(active_streak_without_current_player.id.to_s)
      expect(streak_ids).to include(active_streak_with_current_player.id.to_s)
    end
  end

  describe "PUT #update" do
    xit "reseponds successfully with habit in params" do
      # mock authenticated token
      active_streak = create(:streak, :active, :with_players, {
        players_count: 6
      })
      current_player = active_streak.players.last
      login_as(current_player)

      patch :update, params: add_habit_to_active_streak_update_params(active_streak, current_player), format: :json
      expect(response).to be_success
    end

    xit "creates a new habit for this streak for current player with habit in params" do
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

    it "creates a new habit for this streak for current player" do
      active_streak, current_player = setup_active_streak_current_player

      expect do
        patch :update, params: add_habit_to_active_streak_update_no_habit_or_player_params(active_streak), format: :json
      end.
      to change { Habit.count }.from(0).to(1)
      expect(current_player.reload.habits.count).to eq(1)
      expect(active_streak.habits.count).to eq(1)
    end

    it "returns new habit in response" do
      active_streak, current_player = setup_active_streak_current_player

      patch :update, params: add_habit_to_active_streak_update_no_habit_or_player_params(active_streak), format: :json

      habits_players_data = JSON.parse(response.body)["data"]["relationships"]["habits"]["data"].last
      expect(habits_players_data["id"].to_i).to eq(Habit.last.id)
    end

    context "when a current player adds over the daily limit for the streak" do
      it "does not create a new habit for this streak for current player" do
        streak = create(:streak, :active, max_habits_per_day: 1)
        current_player = streak.players.first
        second_habit_completed_time = Time.zone.now
        first_habit_on_day = create(:habit, {
          streak: streak,
          player: current_player,
          completed_at: second_habit_completed_time - 1.hour
        })

        login_as(current_player)

        expect do
          patch :update, params: add_habit_to_active_streak_update_no_habit_or_player_params(streak), format: :json
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
        active_streak, current_player = setup_active_streak_current_player

        get :show, params: { id: active_streak.id  }, format: :json
        expect(response).to be_success
      end

      it "returns active streak for participant with team_players" do
        active_streak, current_player = setup_active_streak_current_player

        get :show, {
          params: { id: active_streak.id, include: 'habits,team_players,teams,players' },
          format: :json
        }
        team_players_data = JSON.parse(response.body)["data"]["relationships"]["team_players"]["data"].first

        expect(team_players_data["id"].to_i).to eq(active_streak.team_players.first.id)
      end

      it "returns active streak for participant with team" do
        active_streak, current_player = setup_active_streak_current_player

        get :show, {
          params: { id: active_streak.id, include: 'habits,team_players,teams,players'},
          format: :json
        }
        response_body = JSON.parse(response.body)
        team_data = response_body["data"]["relationships"]["team"]["data"]

        expect(team_data["id"].to_i).to eq(active_streak.team.id)
      end

      it "returns habit in response when active streak has habit" do
        active_streak, current_player, habit = setup_active_streak_current_player(with_habit: true)

        get :show, params: { id: active_streak.id, include: 'habits' }, format: :json
        habit_data = JSON.parse(response.body)["data"]["relationships"]["habits"]["data"].first
        expect(habit_data["id"].to_i).to eq(habit.id)
      end

      it "returns the current week goal as part of the streak response" do
        active_streak, current_player, habit = setup_active_streak_current_player(with_habit: true)

        get :show, params: { id: active_streak.id, include: 'habits' }, format: :json

        streak_attributes = JSON.parse(response.body)["data"]["attributes"]
        expect(streak_attributes.keys).to include("current_week_goal")
      end
    end

    context "when you pass parameters for current_week" do
      let(:tuesday_july_3_at_noon) { Time.zone.local(2018, 7, 3, 12, 0, 0) }
      let(:sunday_july_1_midnight) { Time.zone.local(2018, 7, 1, 0, 0, 0) }
      before do
        Timecop.freeze(tuesday_july_3_at_noon)
      end
      after do
        Timecop.return
      end

      it "returns active streak for participant only habits from current week in response" do
        active_streak = create(:streak, :active, activated_at: sunday_july_1_midnight)
        current_player = active_streak.players.last
        habit_in_prior_week = create(:habit, {
          player: current_player,
          streak: active_streak,
          completed_at: Time.zone.now - 1.week
        })
        current_player = active_streak.players.last
        habit_on_tuesday = create(:habit, {
          player: current_player,
          streak: active_streak,
          completed_at: tuesday_july_3_at_noon
        })
        login_as(current_player)

        get :show, params: { 'id' => active_streak.id, 'include' => 'habits', 'filter[habits][current_week]' => true }, format: :json

        habit_data = JSON.parse(response.body)["data"]["relationships"]["habits"]["data"]
        expect(habit_data.count).to eq(1)
        expect(habit_data.first["id"]).to eq(habit_on_tuesday.id.to_s)
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

  def add_habit_to_active_streak_update_no_habit_or_player_params(active_streak)
    {
      id: active_streak.id,
      "data": {
        "type": "streaks",
        "id": "#{active_streak.id}",
      }
    }
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
