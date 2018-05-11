require "rails_helper"

describe OpenStreaksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/open_streaks").to route_to("open_streaks#index")
    end
  end
end
