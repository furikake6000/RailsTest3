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

ActiveRecord::Schema.define(version: 20171208020729) do

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

  create_table "users", force: :cascade do |t|
    t.string "twid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0
    t.datetime "word_updated_at"
  end

  create_table "words", force: :cascade do |t|
    t.string "name"
    t.boolean "detected"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "detectorid"
    t.index ["user_id"], name: "index_words_on_user_id"
  end

end
