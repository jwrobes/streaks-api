class StreakSerializer
  include FastJsonapi::ObjectSerializer
  # Available options :camel, :camel_lower, :dash, :underscore(default)
  #   set_key_transform :camel_lower
  attributes(:id,
             :team_id,
             :activated_at,
             :completed_at,
             :status,
             :habits_per_week,
             :description,
             :title,
             :players)
end
