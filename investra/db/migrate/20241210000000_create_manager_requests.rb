class CreateManagerRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :manager_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :manager, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
