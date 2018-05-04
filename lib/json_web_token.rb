# lib/json_web_token.rb
#
# # frozen_string_literal: true
# require 'net/http'
# require 'uri'
# require 'jwt'

# class JsonWebToken
#   def self.verify(token)
#     JWT.decode(token, nil,
#                true, # Verify the signature of this token
#                algorithm: 'RS256',
#                iss: 'https://cognito-idp.us-west-2.amazonaws.com/us-west-2_9r7u3U9Oj',
#                verify_iss: true) do |header|
#       jwks_hash[header['kid']]
#     end
#   end

#   def self.jwks_hash
#     uri = 'https://cognito-idp.us-west-2.amazonaws.com/us-west-2_9r7u3U9Oj/.well-known/jwks.json'
#     jwks_raw = Net::HTTP.get URI(uri)
#     jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
#     Hash[
#       jwks_keys
#       .map do |k|
#         [
#           k['kid'],
#           JSON::JWK.new(k).to_key,
#         ]
#       end
#     ]
#   end
# end
