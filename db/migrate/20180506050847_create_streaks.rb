class CreateStreaks < ActiveRecord::Migration[5.2]
  def change
    create_table :streaks do |t|
      t.string :title
      t.text :description
      t.integer :habits_per_week
      t.timestamp :started_at
      t.timestamp :ended_at
      t.integer :team_id
      t.string :status, default: "open", null: false

      t.timestamps
    end
  end
end
