class SerializableTeamPlayer < JSONAPI::Serializable::Resource
  type :team_players

  attribute :user_name do
    @object.player.user_name
  end

  attribute :player_id
  attribute :team_id
  attribute :color
end
