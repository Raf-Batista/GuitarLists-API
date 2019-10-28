class AddLocationToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :location, :string
  end
end
