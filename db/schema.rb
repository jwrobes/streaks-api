# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_25_025435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "habits", force: :cascade do |t|
    t.integer "streak_id"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.date "completed_date"
    t.index ["completed_date"], name: "index_habits_on_completed_date"
    t.index ["streak_id", "player_id"], name: "index_habits_on_streak_id_and_player_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "user_name"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.index ["user_name"], name: "index_players_on_user_name", unique: true
    t.index ["uuid"], name: "index_players_on_uuid", unique: true
  end

  create_table "streak_players", force: :cascade do |t|
    t.integer "streak_id"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["streak_id", "player_id"], name: "index_streak_players_on_streak_id_and_player_id"
  end

  create_table "streaks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "habits_per_week"
    t.datetime "ended_at"
    t.integer "team_id"
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "activated_at"
    t.datetime "completed_at"
    t.integer "max_habits_per_day", default: 1, null: false
  end

  create_table "team_players", force: :cascade do |t|
    t.integer "team_id"
    t.integer "player_id"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "player_id"], name: "index_team_players_on_team_id_and_player_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["uuid"], name: "index_teams_on_uuid"
  end

  create_table "weekly_streak_goals", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.decimal "completion_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
