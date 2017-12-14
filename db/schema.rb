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

ActiveRecord::Schema.define(version: 20171214150741) do

  create_table "quests", force: :cascade do |t|
    t.string "type"
    t.string "last_follower"
    t.string "last_following"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "value"
    t.string "target"
    t.string "last_tweet"
    t.string "last_retweet"
    t.index ["user_id"], name: "index_quests_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.boolean "succeed"
    t.integer "user_id"
    t.integer "word_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
    t.index ["word_id"], name: "index_reports_on_word_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "twid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0
    t.datetime "word_updated_at"
    t.integer "current_score_cache"
    t.boolean "admin", default: false
    t.boolean "is_secret"
    t.index ["score"], name: "index_users_on_score"
    t.index ["twid"], name: "index_users_on_twid", unique: true
  end

  create_table "words", force: :cascade do |t|
    t.string "name"
    t.boolean "detected"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "detectorid"
    t.boolean "noticed_detection"
    t.integer "countcache", default: 0
    t.datetime "cached_at"
    t.index ["user_id"], name: "index_words_on_user_id"
  end

end
