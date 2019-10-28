class AddSellerIdToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :seller_id, :integer
  end
end
