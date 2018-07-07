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

ActiveRecord::Schema.define(version: 2018_07_07_152242) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "email", limit: 128
    t.string "password_digest", limit: 128
    t.string "name", limit: 128
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "communities", force: :cascade do |t|
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

end
