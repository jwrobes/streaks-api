#app/controllers/concerns/secured.rb

# frozen_string_literal: true
module Concerns::PlayerSecured
  class InauthenticatedPlayerError < StandardError; end

  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    @auth_token = auth_token
  rescue JWT::VerificationError, JWT::DecodeError, InauthenticatedPlayerError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def authenticated_username
    @auth_token["username"]
  end

  def authenticated_uuid
    @auth_token["sub"]
  end

  def current_player
    @_current_player ||= (
      Player.find_or_create_by(uuid: authenticated_uuid) do |player|
        player.user_name = authenticated_username
      end
    )
  end

  def authenticated_player(auth_token)
    player_client_id = Rails.application.credentials[:aws][:strks_app][:client_id]
    auth_token["client_id"] == player_client_id
  end

  def http_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    end
  end

  def auth_token
    auth_token = ::Lib::JsonWebToken.verify(http_token).first
    raise InauthenticatedPlayerError unless authenticated_player(auth_token)
    auth_token
  end
end
