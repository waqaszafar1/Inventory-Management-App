class StockInventory < ApplicationRecord
  belongs_to :distribution_center
  belongs_to :product

  # delegates
  delegate :name, :sku, :price, to: :product, prefix: "product"
  delegate :name, to: :distribution_center, prefix: "distribution_center"

  # scopes   [dc_id = distribution center id and items_c = items_count ]
  scope :available_stock_for_reserve, -> (dc_id, items_c) {where("available = ? and  distribution_center_id= ? and (items_count - ?) >= 0 ", true, dc_id, items_c)}
  scope :available_stock_for_reduce, -> (dc_id, items_c) {
    where("available = ? and  distribution_center_id= ? and (items_count - ?) >= 0 ", false, dc_id, items_c)}

  scope :available_stock_for_specific_distribution_center, -> (dc_id) {
    where(available: true, distribution_center_id: dc_id)
  }

  scope :available_stock, -> {where(available: true)}
  scope :reserved_stock, -> {where(available: false)}

end
