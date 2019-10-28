class AddModelToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :model, :string
  end
end
