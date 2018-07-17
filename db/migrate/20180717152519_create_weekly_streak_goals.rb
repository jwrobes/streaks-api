class CreateWeeklyStreakGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :weekly_streak_goals do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :completion_percent
      t.timestamps
    end
  end
end
