class CreatePricePoints < ActiveRecord::Migration[8.0]
  def change
    create_table :price_points do |t|
      t.references :stock, null: false, foreign_key: true
      t.decimal :price
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
