require 'rails_helper'

RSpec.describe "streaks#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/streaks_api/v1/streaks/#{streak.id}",
      params: params
  end

  describe 'basic fetch' do
    let!(:streak) { create(:streak) }

    xit 'serializes the resource correctly' do
      make_request
      assert_payload(:streak, streak, json_item)
    end
  end
end
