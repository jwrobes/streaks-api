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

  describe "PUT #update" do
    it "reseponds successfully" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      login_as(current_player)

      patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
      expect(response).to be_success
    end

    it "adds a new player to the open streak" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      login_as(current_player)

      expect do
        patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
      end.
      to change { Player.find(current_player.id).streaks.count }.from(0).to(1)
      expect(Streak.last.players).to include(current_player)
    end

    it "adds a current player to the open streak" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      login_as(current_player)

      expect do
        patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
      end.
      to change { StreakPlayer.count }.from(3).to(4)
    end

    context "when new player added to streak meets minimum players for streak" do

      it "updates status for streak from open to active" do
        open_streak = create(:streak, :open, :with_players, players_count: 5)
        current_player = create(:player)
        login_as(current_player)
        expect do
          patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
        end.
        to change { open_streak.reload.status }.from("open").to("active")
      end

      context "when there is no team for new active streak players" do
        it "creates a new team" do
          open_streak = create(:streak, :open, :with_players, players_count: 5)
          current_player = create(:player)
          login_as(current_player)
          expect do
            patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
          end.
          to change { Team.count }.from(0).to(1)
        end

        it "creates a new team with a uuid of the player ids sorted and joined" do
          open_streak = create(:streak, :open, :with_players, players_count: 5)
          current_player = create(:player)
          login_as(current_player)
          patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
          expect(open_streak.reload.team.uuid).to eq(open_streak.players.map(&:id).sort.join)
        end
      end

      context "when there is already an active streak for the new streak's players" do
        xit "is expected to be a failure" do
          active_streak = create(:streak, :active)
          open_streak = create(:streak, :open)
          current_player = active_streak.players.first
          open_streak.players << active_streak.players.select { |p| p != current_player }
          login_as(current_player)

            patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
          # expect(response).to be_success
          expect(response.body).to eq({})
        end
      end

      context "when there is already a team for players in the newly activated streak" do
        it "does not create a new team" do
          active_streak = create(:streak, :completed)
          open_streak = create(:streak, :open)
          current_player = active_streak.players.first
          open_streak.players << active_streak.players.select { |p| p != current_player }
          login_as(current_player)

          expect do
            patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json
          end.
          not_to change { Team.count }
        end

        it "adds the streak to the team that already has a completed streak for the players in the streak" do
          #set up team with active streak
          active_streak = create(:streak, :completed)

          #set up open streak with all of the active streak players but one
          open_streak = create(:streak, :open)
          current_player = active_streak.players.first
          open_streak.players << active_streak.players.select { |p| p != current_player }

          #login as the one player missing from active streak's team
          login_as(current_player)

          # join the active streak
          patch :update, params: join_active_streak_update_params(open_streak, current_player), format: :json

          expect(open_streak.reload.team).to eq(active_streak.team)
        end
      end
    end
  end

  def join_active_streak_update_params(open_streak, player)
    {
      id: open_streak.id,
      "data": {
        "type": "streaks",
        "id": "#{open_streak.id}",
        "relationships": {
          "players": {
            "data": { "type": "players", "id": "#{player.id}"  }
          }
        }
      }
    }
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
