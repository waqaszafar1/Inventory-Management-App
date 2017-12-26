class Product < ApplicationRecord
  has_many :stock_inventories
  has_many :distribution_centers, through: :stock_inventories
  validates :sku, presence: true

  # below method will return available stock of the product if exists
  # (Here dc_id means distribution
  #  center id)
  def nonreserved_stock_availability_in_distribution_center dc_id, items_count
    stock_inventories.available_stock_for_reserve(dc_id, items_count)
  end

  # Below method will return available reserved stock of the product if exists
  # (Here dc_id means distribution
  #  center id)
  def reserved_stock_availabilty_in_distribution_center dc_id, items_count
    stock_inventories.available_stock_for_reduce(dc_id, items_count)
  end
end
