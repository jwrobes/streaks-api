class AddMaxHabitsPerDayToStreak < ActiveRecord::Migration[5.2]
  def change
    add_column :streaks, :max_habits_per_day, :integer, null: false, default: 1
  end
end
