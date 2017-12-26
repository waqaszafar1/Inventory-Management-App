class ReportsController < ApplicationController

  # CSV Report to show stock on hand (non reserved available stock)
  def generate_stock_on_hand_report
    @available_inventory_stocks = StockInventory.available_stock.includes(:product,:distribution_center)
    stock_on_hand_file = CSV.generate({}) do |csv|
      csv << ['Name','SKU','Price','Stock','Distribution Center']
        @available_inventory_stocks.each {|stock| csv << [stock.product_name,stock.product_sku,stock.product_price.to_f,stock.items_count,stock.distribution_center_name] }
    end
    send_data stock_on_hand_file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;filename=Stock_On_Hand.csv"
  end

  # CSV Report to show pending stock yet to be shipped (reserved stock)
  def generate_pending_stock_yet_to_be_shipped_report
    @reserved_inventory_stocks = StockInventory.reserved_stock.includes(:product,:distribution_center)
    stock_on_hand_file = CSV.generate({}) do |csv|
      csv << ['Name','SKU','Price','Reserved Stock','Distribution Center']
      @reserved_inventory_stocks.each {|stock| csv << [stock.product_name,stock.product_sku,stock.product_price.to_f,stock.items_count,stock.distribution_center_name] }
    end
    send_data stock_on_hand_file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;filename=Pending_Stock_for_Shipment.csv"
  end

end

