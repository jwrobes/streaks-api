class CurrentPlayersController < ApplicationController
  include Concerns::PlayerSecured

  def show
    render json: current_player, status: :ok
  end
end
