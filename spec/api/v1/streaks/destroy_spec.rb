require 'rails_helper'

RSpec.describe "streaks#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/streaks_api/v1/streaks/#{streak.id}"
  end

  describe 'basic destroy' do
    let!(:streak) { create(:streak) }

    xit 'updates the resource' do
      expect {
        make_request
      }.to change { Streak.count }.by(-1)

      expect(response.status).to eq(200)
      expect(json).to eq('meta' => {})
    end
  end
end
