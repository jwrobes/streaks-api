class AddCompletedAtToHabit < ActiveRecord::Migration[5.2]
  def change
    add_column :habits, :completed_at, :timestamp
  end
end
