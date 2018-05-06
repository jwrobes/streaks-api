class CreateTeamPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :team_players do |t|
      t.integer :team_id
      t.integer :player_id
      t.string :color

      t.timestamps
    end
    add_index :team_players, [:team_id, :player_id]
  end
end
