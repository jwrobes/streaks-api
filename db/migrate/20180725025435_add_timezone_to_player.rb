class AddTimezoneToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :timezone, :string
  end
end
