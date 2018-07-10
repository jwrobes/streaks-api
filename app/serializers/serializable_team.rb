class SerializableTeam < JSONAPI::Serializable::Resource
  type :teams

  attribute :name
  attribute :uuid
  attribute :created_at
  has_many :team_players
end
