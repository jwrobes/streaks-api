class AddCompletionDateToHabit < ActiveRecord::Migration[5.2]
  def change
    add_column :habits, :completed_date, :date
    add_index :habits, :completed_date
  end
end
