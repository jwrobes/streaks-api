require 'rails_helper'

RSpec.describe "streaks#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/streaks_api/v1/current_player/open_streaks", payload
  end

  describe 'basic create' do
    let(:payload) do
      {
        data: {
          type: 'streaks',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    xit 'creates the resource' do
      expect {
        make_request
      }.to change { Streak.count }.by(1)
      streak = Streak.last

      assert_payload(:streak, streak, json_item)
    end
  end
end
