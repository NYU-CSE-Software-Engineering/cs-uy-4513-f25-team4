class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.string :transaction_type, null: false
      t.decimal :price, precision: 15, scale: 2, null: false

      t.timestamps
    end

    add_index :transactions, :transaction_type
    add_index :transactions, :created_at
  end
end
