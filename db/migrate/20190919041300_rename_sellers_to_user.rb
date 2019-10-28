class RenameSellersToUser < ActiveRecord::Migration[5.2]
  def change
    rename_table :sellers, :users
  end
end
