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
end
