require 'rails_helper'

RSpec.describe Api::V1::InventoryController do
  describe "Inventory Add, Reserve, Reduce Flow" do

    # Block which sets few stub data before all the below specs
    before(:all) do
      distribution_center = DistributionCenter.create(name: 'Singapore')
      product = Product.create(name: 'TempPro',sku: '101dove',price: 80.5)
      product.stock_inventories.create(available: true,items_count: 80,
                                       distribution_center_id: distribution_center.id)
      product.stock_inventories.create(available: false,items_count: 30,
                                       distribution_center_id: distribution_center.id)
    end

    # Inventory Flow Test Cases

    it "add inventory with SKU and items_count parameters with distribution center" do
      params = { product: {sku: '10178lux'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 10} }
      post :add_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(200)
    end

    it "add inventory with name SKU and items_count parameters" do
      params = { product: {sku: '10178lux'},inventory_stock: {items_count: 10} }
      post :add_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(403)
    end

    it "add inventory with SKU and distribution center items_count parameters" do
      params = { product: {sku: '10178lux'},distribution_center: {name: 'Singapore'}}
      post :add_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(400)
    end

    it "reserve inventory with SKU which does not exists" do
      params = { product: {sku: '10178luxx'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 10} }
      post :reserve_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(403)
    end

    it "reserve inventory for existing SKU" do
      params = { product: {sku: '10178lux'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 5} }
      post :add_inventory, body: params.to_json , format: :json
      post :reserve_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(200)
    end

    it "reserve inventory for existing SKU but will items count more than available stock" do
      params = { product: {sku: '101dove'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 100} }
      post :reserve_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(403)
    end

    it "reduce inventory for existing SKU but with items count more than available reserved stock" do
      params = { product: {sku: '101dove'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 50} }
      post :reduce_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(403)
    end

    it "reduce inventory for existing SKU non reserved stock" do
      params = { product: {sku: '10178lex'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 50} }
      post :add_inventory, body: params.to_json , format: :json
      post :reduce_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(403)
    end

    it "reduce inventory for existing SKU" do
      params = { product: {sku: '101dove'},distribution_center: {name: 'Singapore'},inventory_stock: {items_count: 20} }
          post :reduce_inventory, body: params.to_json , format: :json
      expect(response).to have_http_status(200)
    end

  end
end