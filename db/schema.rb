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

ActiveRecord::Schema.define(version: 2018_06_17_150807) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "facilities", force: :cascade do |t|
    t.string "name", limit: 1024
    t.text "description"
    t.boolean "is_independent", default: false
    t.boolean "is_assisted", default: false
    t.boolean "is_nursing", default: false
    t.boolean "is_memory", default: false
    t.boolean "is_ccrc", default: false
    t.string "address", limit: 1024
    t.string "address_more", limit: 1024
    t.string "city", limit: 256
    t.string "state", limit: 128
    t.string "postal", limit: 32
    t.string "country", limit: 64
    t.float "lat"
    t.float "lon"
    t.string "website", limit: 1024
    t.string "phone", limit: 64
    t.string "fax", limit: 64
    t.string "email", limit: 256
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facility_keyword", id: false, force: :cascade do |t|
    t.bigint "facility_id", null: false
    t.bigint "keyword_id", null: false
    t.index ["facility_id"], name: "index_facility_keyword_on_facility_id"
  end

  create_table "keyword_groups", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_keyword_groups_on_label"
    t.index ["name"], name: "index_keyword_groups_on_name"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "label", limit: 128
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "keyword_group_id"
    t.index ["keyword_group_id"], name: "index_keywords_on_keyword_group_id"
    t.index ["label"], name: "index_keywords_on_label"
    t.index ["name"], name: "index_keywords_on_name"
  end

  add_foreign_key "keywords", "keyword_groups"
end
