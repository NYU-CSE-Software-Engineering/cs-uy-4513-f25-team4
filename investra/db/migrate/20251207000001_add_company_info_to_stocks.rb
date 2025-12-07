class AddCompanyInfoToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :sector, :string
    add_column :stocks, :market_cap, :decimal, precision: 20, scale: 2
    add_column :stocks, :description, :text
    
    add_index :stocks, :sector
  end
end

