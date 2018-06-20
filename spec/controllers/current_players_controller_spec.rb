require 'rails_helper'

describe CurrentPlayersController, type: :controller do

  describe "GET #show" do
    it "returns a success response with authenticated token" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      get :show, params: {}
      expect(response).to be_success
    end

    it "returns a current player" do
      # mock authenticated token
      current_player = create(:player)
      login_as(current_player)

      get :show, params: {}, format: :json
      expect(JSON.parse(response.body)["id"]).to eq(current_player.id)
      expect(JSON.parse(response.body)["user_name"]).to eq(current_player.user_name)
    end
  end
end
