require 'rails_helper'

describe Concerns::PlayerSecured do
  controller(ApplicationController) do
    include Concerns::PlayerSecured
    def fake_action
      render json: { stuff: "yeah1" }
    end
  end
  before do
    routes.draw {
      get 'fake_action' => 'anonymous#fake_action'
    }
  end

  describe "#authenitcate_request!" do
    let(:http_token) { 'TOKEN' }
    context "with an inauthentic token" do
      before do
        allow(Lib::JsonWebToken).to receive(:verify).with(http_token).and_raise(JWT::VerificationError)
      end

      it "returns error json response" do
        request.headers.merge!(headers(http_token))

        get 'fake_action'
        json = JSON.parse(response.body)
        expect(json).to eq(error_json_response)
      end
    end

    context "with authentic token" do
      it "returns the normal json response when client id is valid" do
        valid_aws_token = aws_token
        mock_json_web_token(http_token, valid_aws_token)

        request.headers.merge!(headers(http_token))
        get 'fake_action'

        json = JSON.parse(response.body)
        expect(json).to eq(dummy_json)
      end

      it "it returns error response with valid token but client id is not" do
        aws_token = aws_token(invalid_client_id: true)
        mock_json_web_token(http_token, aws_token)

        request.headers.merge!(headers(http_token))
        get 'fake_action'

        json = JSON.parse(response.body)
        expect(json).to eq(error_json_response)
      end
    end
  end

  def error_json_response
    { "errors" => ['Not Authenticated'] }
  end

  def dummy_json
    { "stuff" => "yeah1" }
  end

  def mock_json_web_token(http_token, aws_token)
    allow(Lib::JsonWebToken).to receive(:verify).with(http_token).and_return(aws_token)
  end

  def headers(token)
    { "Authorization" => token }
  end

  def aws_token(invalid_client_id: false)
    valid_client_id = Rails.application.credentials[:aws][:strks_app][:client_id]
    client_id  = invalid_client_id ? "bad_client_id" : valid_client_id
    [{
      "username" => "Buddy",
      "sub" => "uuid",
      "client_id" => client_id,
    }]
  end
end
