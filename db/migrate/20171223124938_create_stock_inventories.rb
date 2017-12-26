class CreateStockInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_inventories do |t|
      t.references :distribution_center, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :items_count

      t.timestamps
    end
  end
end
