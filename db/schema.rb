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

ActiveRecord::Schema.define(version: 2021_01_15_101213) do

  create_table "games", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "player1"
    t.bigint "player2"
    t.bigint "winner"
    t.boolean "status"
    t.index ["player1"], name: "fk_rails_1bf4fbc635"
    t.index ["player2"], name: "fk_rails_3fe9109adb"
  end

  create_table "logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "point1"
    t.integer "point2"
    t.datetime "timeplay"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "gameid"
    t.boolean "status"
    t.index ["gameid"], name: "fk_rails_de0f7217d2"
  end

  create_table "players", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "fullname"
    t.string "username"
    t.string "password"
    t.bigint "point"
    t.integer "wincount"
    t.integer "losecount"
    t.boolean "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "games", "players", column: "player1"
  add_foreign_key "games", "players", column: "player2"
  add_foreign_key "logs", "games", column: "gameid"
end
