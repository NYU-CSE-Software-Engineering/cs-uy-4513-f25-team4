class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.references :stock, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.datetime :published_at
      t.string :source
      t.string :url

      t.timestamps
    end
    
    add_index :news, :published_at
    add_index :news, [:stock_id, :published_at]
  end
end

