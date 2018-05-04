require 'rails_helper'

describe Lib::JsonWebToken do
  describe ".verify" do
    let(:token) { 'dfdfdfdfdf' }
    subject { described_class.verify(token) }

    it "should call JWT decode with correct arguments" do
      options = {
        algorithm: 'RS256',
        iss: Rails.application.credentials[:aws][:strks_app][:iss],
        verify_iss: true,
      }
      expect(JWT).to receive(:decode).with(token, nil, true, options)
      subject
    end
  end
  describe ".jwks_hash" do
    let(:mock_jwk_key1) { instance_double(JSON::JWK) }
    let(:mock_jwk_key2) { instance_double(JSON::JWK) }
    let(:converted_key1) { 'converted_key1' }
    let(:converted_key2) { 'converted_key2' }
    before do
      allow(Net::HTTP).to receive(:get).with(URI(Rails.application.credentials[:aws][:strks_app][:jwks_uri])).
        and_return(jwks_raw)
      allow(JSON::JWK).to receive(:new).with(jwks_key1).and_return(mock_jwk_key1)
      allow(JSON::JWK).to receive(:new).with(jwks_key2).and_return(mock_jwk_key2)
      allow(mock_jwk_key1).to receive(:to_key).and_return(converted_key1)
      allow(mock_jwk_key2).to receive(:to_key).and_return(converted_key2)
    end
    subject { described_class.jwks_hash }

    it "returns map of jswon web keys as a hash with the kid as the key" do
      expected_result = {
        "kid1" => converted_key1,
        "kid2" => converted_key2
      }
      expect(subject).to eq(expected_result)
    end

  end

  def jwks_raw
    <<-KEY
    {\"keys\":[{\"alg\":\"RS256\",\"e\":\"AQAB\",\"kid\":\"kid1\",\"kty\":\"RSA\",\"n\":\"nvalue1",\"use\":\"sig\"},{\"alg\":\"RS256\",\"e\":\"AQAB\",\"kid\":\"kid2",\"kty\":\"RSA\",\"n\":\"nvalue2",\"use\":\"sig\"}]}
     KEY
  end

  def jwks_key1
    key1 = <<-KEY
{\"alg\":\"RS256\",\"e\":\"AQAB\",\"kid\":\"kid1",\"kty\":\"RSA\",\"n\":\"nvalue1",\"use\":\"sig\"}
    KEY
    JSON.parse(key1)
  end

  def jwks_key2
    key2 = <<-KEY
{\"alg\":\"RS256\",\"e\":\"AQAB\",\"kid\":\"kid2\",\"kty\":\"RSA\",\"n\":\"nvalue2",\"use\":\"sig\"}
KEY
    JSON.parse(key2)
  end

  def mock_jwk_key1
    mock_jwk_key1 = instance_double(JSON::JWK)
    allow(JSON::JWK).to receive(:new).with(jwks_key1).and_return(mock_jwk_key1)
  end

  def mock_jwk_key2
    mock_jwk_key2 = instance_double(JSON::JWK)
    allow(JSON::JWK).to receive(:new).with(jwks_key2).and_return(mock_jwk_key2)
  end
end
