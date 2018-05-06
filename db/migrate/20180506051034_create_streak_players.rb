class CreateStreakPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :streak_players do |t|
      t.integer :streak_id
      t.integer :player_id

      t.timestamps
    end

    add_index :streak_players, [:streak_id, :player_id]
  end
end
