ActiveRecord::Schema[8.0].define(version: 2025_11_06_213743) do
  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.bigint "company_id"
    t.bigint "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["manager_id"], name: "index_users_on_manager_id"
  end

  add_foreign_key "users", "companies"
  add_foreign_key "users", "users", column: "manager_id"
end
