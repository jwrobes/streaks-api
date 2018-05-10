class ChangeStartedAtAndAddCompletedAtToStreak < ActiveRecord::Migration[5.2]
  def change
    add_column :streaks, :activated_at, :timestamp
    remove_column :streaks, :started_at
    add_column :streaks, :completed_at, :timestamp
  end
end
