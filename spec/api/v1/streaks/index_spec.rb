require 'rails_helper'

RSpec.describe "streaks#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/streaks_api/v1/streaks",
      params: params
  end

  describe 'basic fetch' do
    let!(:streak1) { create(:streak) }
    let!(:streak2) { create(:streak) }

    xit 'serializes the list correctly' do
      make_request
      expect(json_ids(true)).to match_array([streak1.id, streak2.id])
      assert_payload(:streak, streak1, json_items[0])
      assert_payload(:streak, streak2, json_items[1])
    end
  end
end
