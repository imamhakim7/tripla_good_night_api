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

ActiveRecord::Schema[8.0].define(version: 2025_05_08_071640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "activity_type"
    t.datetime "clock_in"
    t.datetime "clock_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "activity_type"], name: "index_activity_sessions_on_user_and_type"
    t.index ["user_id", "clock_in", "clock_out"], name: "index_activity_sessions_on_user_and_times"
    t.index ["user_id"], name: "index_activity_sessions_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action_type"
    t.string "relationable_type", null: false
    t.bigint "relationable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["relationable_type", "relationable_id"], name: "index_relationships_on_relationable"
    t.index ["user_id", "action_type"], name: "index_relationships_on_user_and_action_type"
    t.index ["user_id", "relationable_type", "relationable_id"], name: "index_relationships_on_user_and_relationable"
    t.index ["user_id"], name: "index_relationships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["refresh_token"], name: "index_users_on_refresh_token"
  end

  add_foreign_key "activity_sessions", "users"
  add_foreign_key "relationships", "users"
end
