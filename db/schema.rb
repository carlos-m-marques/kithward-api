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

ActiveRecord::Schema.define(version: 2018_11_01_175308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", limit: 1024
    t.text "description"
    t.string "street", limit: 1024
    t.string "street_more", limit: 1024
    t.string "city", limit: 256
    t.string "state", limit: 128
    t.string "postal", limit: 32
    t.string "country", limit: 64
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "care_type", limit: 1, default: "?"
    t.string "status", limit: 1, default: "?"
    t.jsonb "data"
    t.string "cached_image_url", limit: 128
    t.jsonb "cached_data"
  end

  create_table "community_images", force: :cascade do |t|
    t.bigint "community_id"
    t.string "caption", limit: 1024
    t.string "tags", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 9999
    t.index ["community_id"], name: "index_community_images_on_community_id"
  end

  create_table "geo_places", force: :cascade do |t|
    t.string "reference", limit: 128
    t.string "geo_type", limit: 10
    t.string "name", limit: 255
    t.string "full_name", limit: 255
    t.string "state", limit: 128
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 0
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "community_id"
    t.string "name", limit: 256
    t.string "email", limit: 128
    t.string "phone", limit: 128
    t.string "request", limit: 64
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data"
    t.index ["account_id"], name: "index_leads_on_account_id"
    t.index ["community_id"], name: "index_leads_on_community_id"
  end

  create_table "listing_images", force: :cascade do |t|
    t.bigint "listing_id"
    t.string "caption", limit: 1024
    t.string "tags", limit: 1024
    t.integer "sort_order", default: 9999
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_listing_images_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "community_id"
    t.string "name", limit: 1024
    t.string "status", limit: 1, default: "?"
    t.integer "sort_order", default: 9999
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_listings_on_community_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
