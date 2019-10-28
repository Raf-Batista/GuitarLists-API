class AddSpecToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :spec, :string
  end
end
