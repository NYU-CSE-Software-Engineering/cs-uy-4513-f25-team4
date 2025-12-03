class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end

    add_index :portfolios, [:user_id, :stock_id], unique: true
  end
end
