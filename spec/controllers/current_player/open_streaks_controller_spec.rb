require 'rails_helper'

describe CurrentPlayer::OpenStreaksController, type: :controller do

  describe "POST #create" do
    it "responds successfully" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      post :create, params: streak_params, format: :json
      expect(response).to be_successful
    end

    it "creates a new streak" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      expect { post :create, params: streak_params, format: :json }.
        to change { Streak.count }.from(0).to(1)
    end

    it "creates a new streak with players" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      expect { post :create, params: streak_params, format: :json }.
        to change { StreakPlayer.count }.from(0).to(1)
    end

    it "creates adds current player to streak" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      expect do
        post :create, params: streak_params, format: :json
      end.
      to change { Player.last.streaks.count }.from(0).to(1)
      expect(Streak.last.players.first).to eq(current_player)
    end

    context "with invalid attributes" do
      it "responds with a failure and returns habits per week blank" do
        # mock authenticated token
        current_player = create(:player)
        login_as(current_player)

        post :create, params: invalid_streak_params, format: :json
        expect(response.code).to eq("422")
        expect(JSON.parse(response.body)["errors"].first["detail"]).to eq("Habits per week can't be blank")
      end
    end
  end

  describe "PUT #update" do
    it "reseponds successfully" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      login_as(current_player)

      patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
      expect(response).to be_successful
    end

    it "adds a new player to the open streak" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      login_as(current_player)

      expect do
        patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
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
        patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
      end.
      to change { StreakPlayer.count }.from(3).to(4)
    end

    context "when a player tries to join a streak they already have joined" do

      it "does not add the player to the streak" do
        open_streak = create(:streak, :open, :with_players)
        current_player = create(:player)
        open_streak.players << current_player
        open_streak.save
        login_as(current_player)

        expect do
          patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
        end.
        not_to change { StreakPlayer.count }
      end

      it "returns a 422 with correct errors" do
        open_streak = create(:streak, :open, :with_players)
        current_player = create(:player)
        open_streak.players << current_player
        open_streak.save
        login_as(current_player)

        patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
        expect(response.code).to eq("422")
        expect(JSON.parse(response.body)["errors"].first["detail"]).to eq("Validation failed: Player can only join a streak once.")
      end
    end

    context "when new player added to streak meets minimum players for streak" do

      it "updates status for streak from open to active" do
        open_streak = create(:streak, :open, :with_players, players_count: 5)
        current_player = create(:player)
        login_as(current_player)
        expect do
          patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
        end.
        to change { open_streak.reload.status }.from("open").to("active")
      end

      context "when there is no team for new active streak players" do
        it "creates a new team" do
          open_streak = create(:streak, :open, :with_players, players_count: 5)
          current_player = create(:player)
          login_as(current_player)
          expect do
            patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
          end.
          to change { Team.count }.from(0).to(1)
        end

        it "creates a new team with a uuid of the player ids sorted and joined" do
          open_streak = create(:streak, :open, :with_players, players_count: 5)
          current_player = create(:player)
          login_as(current_player)
          patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
          expect(open_streak.reload.team.uuid).to eq(open_streak.players.map(&:id).sort.join)
        end
      end

      context "when there is already an active streak for the new streak's players" do
        it "is expected to not add player" do
          active_streak = create(:streak, :active)
          open_streak = create(:streak, :open)
          current_player = active_streak.players.first
          open_streak.players << active_streak.players.last(5)
          login_as(current_player)
          expect do
          patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
          end.
          not_to change{StreakPlayer.count}
          expect(response.code).to eq("422")
          expect(JSON.parse(response.body)["errors"].first["detail"]).to eq("Validation failed: Team has already been taken")
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
            patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
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
          patch :update, params: join_active_streak_update_params_no_player_id(open_streak), format: :json

          expect(open_streak.reload.team).to eq(active_streak.team)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    it "responds successfully" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      open_streak.players << current_player
      login_as(current_player)

      delete :destroy, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
      expect(response).to be_successful
    end

    it "removes the current player from the open streak" do
      # mock authenticated token
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      open_streak.players << current_player
      login_as(current_player)

      delete :destroy, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
      expect(open_streak.reload.players).not_to include(current_player)
    end

    it "returns streak response with other players still included" do
      open_streak = create(:streak, :open, :with_players)
      current_player = create(:player)
      open_streak.players << current_player
      login_as(current_player)

      delete :destroy, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
      expect(response.code).to eq("200")
      response_body = JSON.parse(response.body)
      player_ids =  response_body["data"]["relationships"]["players"]["data"].map { |p| p["id"] }
      expect(player_ids).to match_array(open_streak.reload.players.map{ |p| p.id.to_s })
    end

    context "when there only the current player is in the open streak prior to delete" do

      it "destroys the open streak" do
        open_streak = create(:streak, :open)
        current_player = create(:player)
        open_streak.players << current_player
        login_as(current_player)

        delete :destroy, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
        expect(Streak.where(id: open_streak.id).count).to eq(0)
      end

      it "destroys the open streak" do
        open_streak = create(:streak, :open)
        current_player = create(:player)
        open_streak.players << current_player
        login_as(current_player)

        delete :destroy, params: join_active_streak_update_params_no_player_id(open_streak), format: :json
        expect(response.code).to eq("200")
        # expect(JSON.parse(response.body)).to eq({})
      end
    end
  end


  def join_active_streak_update_params_no_player_id(open_streak)
    {
      id: open_streak.id,
      "data": {
        "type": "streaks",
        "id": "#{open_streak.id}",
      }
    }
  end

  def join_active_streak_update_params(open_streak)
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
          "habits_per_week": 1,
          "description": "This is where you eat freaking cake bitch"
        }
      }
    }
  end

  def invalid_streak_params
    {
      "data": {
        "type": "streaks",
        "attributes": {
          "title": "Eat cake every day",
          "description": "This is where you eat freaking cake bitch"
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
          id: "#{player.id}",
        }
      ]
    }
  end

end
