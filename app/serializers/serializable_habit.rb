# Serializers define the rendered JSON for a model instance.
class SerializableHabit < JSONAPI::Serializable::Resource
  type :habits

  # Add attributes here to ensure they get rendered, .e.g.
  #
  # attribute :name
  #
  # To customize, pass a block and reference the underlying @object
  # being serialized:
  #
  # attribute :color do
  #   @object.name.upcase
  # end
  attribute :player_id
  attribute :streak_id
  attribute :completed_at
end
