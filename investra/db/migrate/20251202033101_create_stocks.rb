class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.string :symbol, null: false
      t.string :name, null: false
      t.decimal :price, precision: 15, scale: 2, null: false
      t.integer :available_quantity, null: false, default: 0

      t.timestamps
    end

    add_index :stocks, :symbol, unique: true
  end
end
