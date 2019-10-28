class ChangeSellerIdToUserId < ActiveRecord::Migration[5.2]
  def change
    rename_column :guitars, :seller_id, :user_id
  end
end
