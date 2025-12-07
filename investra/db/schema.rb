# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_07_211937) do
  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticker"
    t.string "sector"
    t.decimal "market_cap", precision: 15, scale: 2
    t.boolean "tradable", default: true
    t.date "ipo_date"
    t.string "domain"
    t.index ["ticker"], name: "index_companies_on_ticker", unique: true
  end

  create_table "credit_lines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "credit_limit", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "credit_used", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credit_lines_on_user_id"
  end

  create_table "holdings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "symbol"
    t.decimal "shares", precision: 10
    t.decimal "average_cost", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_holdings_on_user_id"
  end

  create_table "news", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.string "title", null: false
    t.text "content"
    t.datetime "published_at"
    t.string "source"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "index_news_on_published_at"
    t.index ["stock_id", "published_at"], name: "index_news_on_stock_id_and_published_at"
    t.index ["stock_id"], name: "index_news_on_stock_id"
  end

  create_table "portfolios", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_portfolios_on_stock_id"
    t.index ["user_id", "stock_id"], name: "index_portfolios_on_user_id_and_stock_id", unique: true
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "price_points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recorded_at"], name: "index_price_points_on_recorded_at"
    t.index ["stock_id", "recorded_at"], name: "index_price_points_on_stock_id_and_recorded_at"
    t.index ["stock_id"], name: "index_price_points_on_stock_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "stocks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.integer "available_quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sector"
    t.decimal "market_cap", precision: 20, scale: 2
    t.text "description"
    t.index ["sector"], name: "index_stocks_on_sector"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
  end

  create_table "trades", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "symbol"
    t.string "trade_type"
    t.decimal "shares", precision: 10
    t.decimal "price", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.integer "quantity", null: false
    t.string "transaction_type", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["stock_id"], name: "index_transactions_on_stock_id"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
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
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["manager_id"], name: "index_users_on_manager_id"
  end

  create_table "watchlists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "symbol", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "symbol"], name: "index_watchlists_on_user_id_and_symbol", unique: true
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "credit_lines", "users"
  add_foreign_key "holdings", "users"
  add_foreign_key "news", "stocks"
  add_foreign_key "portfolios", "stocks"
  add_foreign_key "portfolios", "users"
  add_foreign_key "price_points", "stocks"
  add_foreign_key "trades", "users"
  add_foreign_key "transactions", "stocks"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "users", column: "manager_id"
  add_foreign_key "watchlists", "users"
end
