class AddPriceToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :price, :integer
  end
end
