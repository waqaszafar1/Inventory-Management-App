Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    namespace :api, defaults:{ format: :json }do
      namespace :v1 do
        post 'add_inventory' => 'inventory#add_inventory'
        post 'reduce_inventory' => 'inventory#reduce_inventory'
        post 'reserve_inventory' => 'inventory#reserve_inventory'
      end
    end
    get 'reports/stock_on_hand' => 'reports#generate_stock_on_hand_report'
    get 'reports/pending_shipped_inventory' =>  'reports#generate_pending_stock_yet_to_be_shipped_report'
end
