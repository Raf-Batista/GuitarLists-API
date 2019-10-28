class CreateGuitars < ActiveRecord::Migration[5.2]
  def change
    create_table :guitars do |t|

      t.timestamps
    end
  end
end
