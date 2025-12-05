class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      t.references :user, null: false, foreign_key: true
      t.string :symbol
      t.string :trade_type
      t.decimal :shares
      t.decimal :price

      t.timestamps
    end
  end
end
