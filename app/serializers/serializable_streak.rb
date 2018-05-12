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
  attribute :description
  attribute :title
  has_many :players
end
