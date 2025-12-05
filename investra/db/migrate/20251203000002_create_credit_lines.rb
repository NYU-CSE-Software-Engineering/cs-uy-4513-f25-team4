class CreateCreditLines < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_lines do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :credit_limit, precision: 15, scale: 2, default: 0, null: false
      t.decimal :credit_used, precision: 15, scale: 2, default: 0, null: false

      t.timestamps
    end
  end
end
