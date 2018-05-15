class AddUuidToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :uuid, :string, unique: true, null: false
    add_index :teams, :uuid
  end
end
