# # frozen_string_literal: true
require 'net/http'
require 'uri'
require 'jwt'

class Lib::JsonWebToken
  def self.verify(token)
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithm: 'RS256',
               iss: Rails.application.credentials[:aws][:strks_app][:iss],
               verify_iss: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    uri = Rails.application.credentials[:aws][:strks_app][:jwks_uri]
    jwks_raw = Net::HTTP.get URI(uri)
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          convert_to_open_ssl_key(k),
        ]
      end
    ]
  end

  def self.convert_to_open_ssl_key(key)
    JSON::JWK.new(key).to_key
  end
end
