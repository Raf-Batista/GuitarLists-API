class AddConditionToGuitar < ActiveRecord::Migration[5.2]
  def change
    add_column :guitars, :condition, :string 
  end
end
