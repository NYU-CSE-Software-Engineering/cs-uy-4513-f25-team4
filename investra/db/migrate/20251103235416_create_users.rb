class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :role
      # company_id created without foreign key constraint initially
      # (companies table doesn't exist yet, and FK will be added later if needed)
      t.references :company, null: true, foreign_key: false
      # manager_id references users table (self-referential, but users table exists)
      t.references :manager, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
