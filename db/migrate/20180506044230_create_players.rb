class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :user_name
      t.string :uuid

      t.timestamps
    end
    add_index :players, :user_name, unique: true
    add_index :players, :uuid, unique: true
  end
end
