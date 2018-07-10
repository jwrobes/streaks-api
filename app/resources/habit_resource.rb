# Define how to query and persist a given model.
class HabitResource < ApplicationResource
  # Used for associating this resource with a given input.
  # This should match the 'type' in the corresponding serializer.
  type :habits
  model Habit

  allow_filter :current_week do |scope|
    scope.current_week
  end

  # Customize your resource here. Some common examples:
  def create(create_params)
    create_params[:completed_at] = Time.zone.parse(create_params[:completed_at])
    m = model.new(create_params)
    m.save
    m
  end

  belongs_to :streak,
    scope: -> { Streak.all  },
    resource: StreakResource,
    foreign_key: :streak_id
end
