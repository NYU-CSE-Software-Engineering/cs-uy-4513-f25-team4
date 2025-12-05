class CreateWatchlists < ActiveRecord::Migration[8.0]
  def change
    create_table :watchlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :symbol, null: false

      t.timestamps
    end

    add_index :watchlists, [:user_id, :symbol], unique: true
  end
end
