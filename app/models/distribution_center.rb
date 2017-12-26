class DistributionCenter < ApplicationRecord
  has_many :stock_inventories
  has_many :products, through: :stock_inventories
end
