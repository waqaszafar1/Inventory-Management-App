class AddAvailableToStockInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :stock_inventories, :available, :boolean
  end
end
