class Api::V1::InventoryController < ApplicationController

  # filter for product's availability check for reservations and reduction
  before_action :get_distribution_center
  before_action :check_product_stock_availability_in_distribution_center_for_reservations,
                only: :reserve_inventory
  before_action :check_product_stock_availability_in_distribution_center_for_reductions,
                only: :reduce_inventory


  # action to add inventory in distribution center
  def add_inventory
    begin
      if product_params[:sku].present? && inventory_stock_params[:items_count].present?

        # SKU will remain unique through out the course of application
        @product = Product.find_by_sku(product_params[:sku])
        if @product.present?
          # In case of existing product with provided SKU, product will get updated with
          # parameters of name and price if provided .
          @product.update_attributes!(product_params) if product_params[:name] ||
              product_params[:price]
        else
          # In case of no product found with provided SKU, then new product will be created
          @product = Product.create!(product_params)
        end
        @product_stock = @product.stock_inventories
                             .available_stock_for_specific_distribution_center(@distribution_center.id).first

        # If there isn't any stock entry for such product in specified distribution center.
        @product_stock = @product.stock_inventories.create!(available: true,
                                                            items_count: 0,
                                                            distribution_center_id:
                                                                @distribution_center.id) unless @product_stock.present?

        # Update the inventory count.
        if @product_stock.update_attribute(:items_count,
                                           @product_stock.items_count +
                                               inventory_stock_params[:items_count].to_i)
          response = {message: "Inventory has been updated successfully."}
          status_code = 200
        else
          response = {errors:
                          [{detail: "We can't apply this operation at this time, please try later."}]}
          status_code = 403
        end
      else
        response = {errors:
                        [{detail: "Required parameters are missing."}]}
        status_code = 400
      end
    rescue => ex
      response = {errors: [{detail: ex.message}]}
      status_code = 403
    end
    render json: response, status: status_code
  end

  # action to reserve inventory in distribution center for later reduction (actually pending
  # inventory to be shipped.)
  def reserve_inventory
    begin
      @product_reserved_stock = @product.reserved_stock_availabilty_in_distribution_center(
          @distribution_center.id, inventory_stock_params[:items_count]).first
      unless @product_reserved_stock.present?
        @product_reserved_stock = @product.stock_inventories.create!(available: false,
                                                                     items_count: 0,
                                                                     distribution_center_id:
                                                                         @distribution_center.id)
      end
      if @product_available_stock.update_attribute(:items_count,
                                                   @product_available_stock.items_count -
                                                       inventory_stock_params[:items_count]) &&
          @product_reserved_stock.update_attribute(:items_count,
                                                   @product_reserved_stock.items_count +
                                                       inventory_stock_params[:items_count])

        response = {message: 'Inventory has been reserved of particular product stock in specified distribution center.'}
        status_code = 200
      else
        response = {errors:
                        [{detail: "We can't apply this operation at this time, please try later."}]}
        status_code = 403
      end
    rescue => ex
      response = {errors: [{detail: ex.message}]}
      status_code = 403
    end
    render json: response, status: status_code
  end


  # action to  reduce inventory in distribution center
  # inventory will be reserved first and reduced later from reserved inventory.
  def reduce_inventory
    begin
      if @product_available_stock.update_attribute(:items_count,
                                                   @product_available_stock.items_count -
                                                       inventory_stock_params[:items_count])
        response = {message: 'Inventory has been reduced of particular product stock of in  specified distribution center.'}
        status_code = 200
      else
        response = {errors:
                        [{detail: "We can't apply this operation at this time, please try later."}]}
        status_code = 403
      end
    rescue => ex
      response = {errors: [{detail: ex.message}]}
      status_code = 403
    end
    render json: response, status: status_code
  end


  private
  def get_distribution_center
    begin
      @distribution_center = DistributionCenter.find_by_name(
          distribution_center_params[:name]) if distribution_center_params[:name].present?
      unless @distribution_center.present?
        errors = {errors: [{detail: "No distribution center found, check distribution center parameter again."}]}
        render json: errors, status: 403
      end
    rescue => ex
      errors = {errors: [{detail: ex.message}]}
      render json: errors, status: 403
    end
  end

  def check_product_stock_availability_in_distribution_center_for_reservations
    begin
      @product = Product.find_by_sku(product_params[:sku]) if product_params[:sku].present?

      # Here we are looking for any non-reserved stock for the particular product in warehouse
      @product_available_stock = @product.nonreserved_stock_availability_in_distribution_center(
          @distribution_center.id, inventory_stock_params[:items_count]).first if @product.present?

      unless @product.present? && @product_available_stock.present?
        errors = {errors:
                      [{detail: "No such product or its stock available in specified distribution center against
the provided SKU parameter.It May be out/short of stock for reservation."}]}
        render json: errors, status: 403
      end
    rescue => ex
      errors = {errors: [{detail: ex.message}]}
      render json: errors, status: 403
    end
  end

  def check_product_stock_availability_in_distribution_center_for_reductions
    begin
      @product = Product.find_by_sku(product_params[:sku]) if product_params[:sku].present?

      # Here we are looking for any reserved stock for the particular product in warehouse
      # Only those product will be reduced which are reserved before by customer
      @product_available_stock = @product.reserved_stock_availabilty_in_distribution_center(
          @distribution_center.id, inventory_stock_params[:items_count]).first if @product.present?

      unless @product.present? &&
          @product_available_stock.present?
        errors = {errors:
                      [{detail: "No such product or its reserved stock available in specified distribution
center against the provided SKU parameter. Only previously reserved stock can be reducted."}]}
        render json: errors, status: 403
      end
    rescue => ex
      errors = {errors: [{detail: ex.message}]}
      render json: errors, status: 403
    end
  end

  def product_params
    begin
      product_params = ActionController::Parameters.new(JSON.parse(request.raw_post))
      product_params.require(:product).permit(:name,
                                              :sku,
                                              :price)
    rescue => ex
      product_params = ActionController::Parameters.new()
    end
  end

  def distribution_center_params
    begin
      distribution_center_params = ActionController::Parameters.new(JSON.parse(request.raw_post))
      distribution_center_params.require(:distribution_center).permit(:name)
    rescue => ex
      product_params = ActionController::Parameters.new()
    end
  end

  def inventory_stock_params
    begin
      inventry_stock_params = ActionController::Parameters.new(JSON.parse(request.raw_post))
      inventry_stock_params.require(:inventory_stock).permit(:items_count)
    rescue => ex
      product_params = ActionController::Parameters.new()
    end
  end
end

