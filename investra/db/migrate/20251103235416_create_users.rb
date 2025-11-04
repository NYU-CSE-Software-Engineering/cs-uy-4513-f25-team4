class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :role
      t.references :company, null: false, foreign_key: true
      t.references :manager, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
