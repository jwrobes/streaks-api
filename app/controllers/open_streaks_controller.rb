class OpenStreaksController < ApplicationController
  # before_action :set_open_streak, only: [:show, :update, :destroy]
  include Concerns::PlayerSecured

  def index
    @open_streaks = Streak.open.all
    render json: StreakSerializer.new(@open_streaks), status: :ok
  end
end
