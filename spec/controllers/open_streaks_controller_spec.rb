require 'rails_helper'

describe OpenStreaksController, type: :controller do

  describe "GET #index" do
    it "returns a success response with authenticated token" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      open_streak_with_players = create(:streak, :open, :with_players, players_count: 4)
      active_streak_with_players = create(:streak, :active, :with_players, players_count: 6)

      get :index, params: {}, format: :json
      expect(response).to be_success
    end

    it "only return open streaks" do
      current_player = create(:player)
      login_as(current_player)

      open_streak_with_players = create(:streak, :open, :with_players, players_count: 4)
      active_streak_with_players = create(:streak, :active, :with_players, players_count: 6)

      get :index, params: {}, format: :json
      data = JSON.parse(response.body)["data"]
      streak_ids = data.map {|r| r["id"]}
      expect(streak_ids).not_to include(active_streak_with_players.id.to_s)
    end
  end

  describe "POST #create" do
    it "responds successfully" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      post :create, params: streak_params, format: :json
      expect(response).to be_success
    end

    it "creates a new streak" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      expect { post :create, params: streak_params, format: :json }.
        to change { Streak.count }.from(0).to(1)
    end

    context "with player attributes" do
      it "creates a new streak" do
        # mock authenticated token
        current_player = create(:player)
        login_as(current_player)

        expect { post :create, params: streak_params_with_players(current_player), format: :json }.
          to change { Streak.count }.from(0).to(1)
      end

      it "creates a new streak with players" do
        # mock authenticated token
        current_player = create(:player)
        login_as(current_player)

        expect do
          post :create, params: streak_params_with_players(current_player), format: :json
        end.
          to change { StreakPlayer.count }.from(0).to(1)
      end

      it "creates adds current player to streak" do
        # mock authenticated token
        current_player = create(:player)
        login_as(current_player)

        expect do
          post :create, params: streak_params_with_players(current_player), format: :json
        end.
        to change { Player.last.streaks.count }.from(0).to(1)
        expect(Streak.last.players.first).to eq(current_player)
      end
    end
  end

  def streak_params
    {
      "data": {
        "type": "streaks",
        "attributes": {
          "title": "Eat cake every day",
          "description": "This is where you eat freaking cake bitch",
          "habits_per_week": 7,
        }
      }
    }
  end

  def streak_params_with_players(player)
    {
      "data": {
        "type": "streaks",
        "attributes": {
          "title": "Eat cake every day",
          "description": "This is where you eat freaking cake bitch",
          "habits_per_week": 7,

        },
        "relationships": {
          "players": {
            "data": { "type": "players", "id": "#{player.id}"  }
          }
        }
      },
      included: [
        {
          type: "players",
          id: "1",
        }
      ]
    }
  end

end
