class AddDetailsToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :ticker, :string
    add_column :companies, :sector, :string
    add_column :companies, :market_cap, :decimal, precision: 15, scale: 2
    add_column :companies, :tradable, :boolean, default: true
    add_column :companies, :ipo_date, :date

    add_index :companies, :ticker, unique: true
  end
end
