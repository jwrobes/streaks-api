# Serializers define the rendered JSON for a model instance.
# We use jsonapi-rb, which is similar to active_model_serializers.
class SerializableStreak < JSONAPI::Serializable::Resource
  type :streaks

  attribute :id
  attribute :team_id
  attribute :activated_at
  attribute :completed_at
  attribute :status
  attribute :habits_per_week
  attribute :max_habits_per_day
  attribute :description
  attribute :title
  attribute :total_habits_in_week do
    @object.habits_per_week * @object.players.count
  end
  has_many :players
  has_many :habits
  has_many :team_players
  has_one :team
end
