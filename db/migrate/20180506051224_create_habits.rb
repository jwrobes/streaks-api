class CreateHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :habits do |t|
      t.integer :streak_id
      t.integer :player_id

      t.timestamps
    end
    add_index :habits, [:streak_id, :player_id]
  end
end
