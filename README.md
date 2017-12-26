# Inventory Management 

This guide would normally document whatever steps are necessary to get the
application up and running.

## Setup

* clone repo

* run `bundle install`

* run `rake db:setup`

## End Points

#### For Adding Inventory 
* If the sku is unique then it will create new product along with its stock entry.SKU and items_count are the mandotory fields.If the sku already exists in the system then it will update the stock items of it. In case you provide name or price in add inventory call for an existing sku then it will update those fields.
  
     `POST http://localhost:3000/api/v1/add_inventory`
     
  ##### request body
  
  `{
          "product": {
          "sku": "1045dove",
          "name": "dove",
          "price": 10.5
          },
          "distribution_center": {
          "name": "Singapore"
          },
          "inventory_stock": {
          "items_count": 1
          }
        }`

#### For Reserving Inventory 
* It will reserve the stock from available stock for later reduction for the given SKU in specified distribution center.
  
     `POST http://localhost:3000/api/v1/reserve_inventory`
     
  ##### request body
  
  `{
          "product": {
          "sku": "1045dove"
          },
          "distribution_center": {
          "name": "Singapore"
          },
          "inventory_stock": {
          "items_count": 2
          }
        }`

#### For Reducing Inventory 
* It will reduce the stock from reserved stock for the given SKU in specified distribution center.
  
     `POST http://localhost:3000/api/v1/reduce_inventory`
     
  ##### request body
  
  `{
          "product": {
          "sku": "1045dove"
          },
          "distribution_center": {
          "name": "Singapore"
          },
          "inventory_stock": {
          "items_count": 1
          }
        }`


#### Reports  
* Link to get CSV Report Stock On Hand Stock.
  
     `GET http://localhost:3000/reports/stock_on_hand`
     
* Link to get CSV Report of Pending Shipped Inventory     
     
     `GET http://localhost:3000/reports/pending_shipped_inventory`
 
## Automated Tests 

* Below are the commands to run automated tests written for end points

  `bundle exec rspec` or `bundle exec rspec spec/controllers/api/v1/inventory_controller_spec.rb`

* ...
