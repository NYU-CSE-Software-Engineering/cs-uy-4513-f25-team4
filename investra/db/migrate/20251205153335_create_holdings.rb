class CreateHoldings < ActiveRecord::Migration[8.0]
  def change
    create_table :holdings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :symbol
      t.decimal :shares
      t.decimal :average_cost

      t.timestamps
    end
  end
end
