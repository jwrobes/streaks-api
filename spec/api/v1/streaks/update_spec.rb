require 'rails_helper'

RSpec.describe "streaks#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/streaks_api/v1/streaks/#{streak.id}", payload
  end

  describe 'basic update' do
    let!(:streak) { create(:streak) }

    let(:payload) do
      {
        data: {
          id: streak.id.to_s,
          type: 'streaks',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect {
        make_request
      }.to change { streak.reload.attributes }
      assert_payload(:streak, streak, json_item)

      # ... assert updates attributes ...
    end
  end
end
