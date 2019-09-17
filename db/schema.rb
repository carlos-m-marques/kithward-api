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

ActiveRecord::Schema.define(version: 2019_09_11_000602) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "account_access_request_communities", force: :cascade do |t|
    t.bigint "account_access_request_id"
    t.bigint "community_id"
    t.index ["account_access_request_id"], name: "index_aar_communities_on_account_access_request_id"
    t.index ["community_id"], name: "index_aar_communities_on_community_id"
  end

  create_table "account_access_requests", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "phone_number"
    t.string "company_name"
    t.text "company_type"
    t.text "reason"
    t.string "work_email"
    t.integer "account_id"
    t.string "state"
    t.index ["account_id"], name: "index_account_access_requests_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "email", limit: 128
    t.string "password_digest", limit: 128
    t.string "name", limit: 128
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", limit: 1, default: "?"
    t.string "verified_email", limit: 128
    t.string "verification_token", limit: 64
    t.datetime "verification_expiration"
    t.string "role", default: "user"
    t.integer "owner_id"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
  end

  create_table "accounts_communities", id: false, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "community_id", null: false
    t.index ["account_id", "community_id"], name: "index_accounts_communities_on_account_id_and_community_id"
    t.index ["community_id", "account_id"], name: "index_accounts_communities_on_community_id_and_account_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
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

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "community_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "flagged_at"
    t.string "flagged_for"
    t.index ["community_id"], name: "index_buildings_on_community_id"
    t.index ["deleted_at"], name: "index_buildings_on_deleted_at"
    t.index ["flagged_at"], name: "index_buildings_on_flagged_at"
    t.index ["flagged_for"], name: "index_buildings_on_flagged_for"
  end

  create_table "buildings_kw_values", id: false, force: :cascade do |t|
    t.bigint "building_id", null: false
    t.bigint "kw_value_id", null: false
    t.index ["building_id", "kw_value_id"], name: "index_buildings_kw_values_on_building_id_and_kw_value_id"
    t.index ["kw_value_id", "building_id"], name: "index_buildings_kw_values_on_kw_value_id_and_building_id"
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", limit: 1024
    t.text "description"
    t.string "street", limit: 1024
    t.string "street_more", limit: 1024
    t.string "city", limit: 256, null: false
    t.string "state", limit: 128, null: false
    t.string "postal", limit: 32, null: false
    t.string "country", limit: 64, null: false
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "care_type", limit: 1, default: "?"
    t.string "status", default: "?"
    t.jsonb "data"
    t.string "cached_image_url", limit: 128
    t.jsonb "cached_data"
    t.float "monthly_rent_lower_bound"
    t.float "monthly_rent_upper_bound"
    t.bigint "owner_id", null: false
    t.bigint "pm_system_id", null: false
    t.string "region", null: false
    t.string "metro"
    t.string "borough"
    t.string "county", null: false
    t.string "township"
    t.datetime "deleted_at"
    t.datetime "flagged_at"
    t.string "flagged_for"
    t.string "slug"
    t.index ["deleted_at"], name: "index_communities_on_deleted_at"
    t.index ["flagged_at"], name: "index_communities_on_flagged_at"
    t.index ["flagged_for"], name: "index_communities_on_flagged_for"
    t.index ["id"], name: "index_communities_on_id"
    t.index ["name"], name: "index_communities_on_name", opclass: :gist_trgm_ops, using: :gist
    t.index ["owner_id"], name: "index_communities_on_owner_id"
    t.index ["pm_system_id"], name: "index_communities_on_pm_system_id"
    t.index ["slug"], name: "index_communities_on_slug", unique: true
  end

  create_table "communities_kw_values", id: false, force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "kw_value_id", null: false
    t.index ["community_id", "kw_value_id"], name: "index_communities_kw_values_on_community_id_and_kw_value_id"
    t.index ["kw_value_id", "community_id"], name: "index_communities_kw_values_on_kw_value_id_and_community_id"
  end

  create_table "communities_pois", id: false, force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "poi_id", null: false
    t.index ["community_id"], name: "index_communities_pois_on_community_id"
    t.index ["poi_id"], name: "index_communities_pois_on_poi_id"
  end

  create_table "community_images", force: :cascade do |t|
    t.bigint "community_id"
    t.string "caption", limit: 1024
    t.string "tags", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 9999
    t.boolean "published", default: true
    t.index ["community_id"], name: "index_community_images_on_community_id"
  end

  create_table "community_share_hits", force: :cascade do |t|
    t.bigint "community_id"
    t.string "from"
    t.string "tracking"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_community_share_hits_on_community_id"
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

  create_table "kw_attributes", force: :cascade do |t|
    t.bigint "kw_class_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ui_type", default: "select"
    t.boolean "required", default: false
    t.boolean "hidden", default: false
    t.index ["kw_class_id"], name: "index_kw_attributes_on_kw_class_id"
    t.index ["ui_type"], name: "index_kw_attributes_on_ui_type"
  end

  create_table "kw_classes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kw_super_class_id"
    t.index ["kw_super_class_id"], name: "index_kw_classes_on_kw_super_class_id"
  end

  create_table "kw_super_classes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.boolean "independent_living", default: false, null: false
    t.boolean "assisted_living", default: false, null: false
    t.boolean "skilled_nursing", default: false, null: false
    t.boolean "memory_care", default: false, null: false
    t.index ["type"], name: "index_kw_super_classes_on_type"
  end

  create_table "kw_values", force: :cascade do |t|
    t.bigint "kw_attribute_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kw_attribute_id"], name: "index_kw_values_on_kw_attribute_id"
  end

  create_table "kw_values_owners", id: false, force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.bigint "kw_value_id", null: false
    t.index ["kw_value_id", "owner_id"], name: "index_kw_values_owners_on_kw_value_id_and_owner_id"
    t.index ["owner_id", "kw_value_id"], name: "index_kw_values_owners_on_owner_id_and_kw_value_id"
  end

  create_table "kw_values_pm_systems", id: false, force: :cascade do |t|
    t.bigint "pm_system_id", null: false
    t.bigint "kw_value_id", null: false
    t.index ["kw_value_id", "pm_system_id"], name: "index_kw_values_pm_systems_on_kw_value_id_and_pm_system_id"
    t.index ["pm_system_id", "kw_value_id"], name: "index_kw_values_pm_systems_on_pm_system_id_and_kw_value_id"
  end

  create_table "kw_values_unit_types", id: false, force: :cascade do |t|
    t.bigint "kw_value_id", null: false
    t.bigint "unit_type_id", null: false
    t.index ["kw_value_id", "unit_type_id"], name: "index_kw_values_unit_types_on_kw_value_id_and_unit_type_id"
    t.index ["unit_type_id", "kw_value_id"], name: "index_kw_values_unit_types_on_unit_type_id_and_kw_value_id"
  end

  create_table "kw_values_units", id: false, force: :cascade do |t|
    t.bigint "kw_value_id", null: false
    t.bigint "unit_id", null: false
    t.index ["kw_value_id", "unit_id"], name: "index_kw_values_units_on_kw_value_id_and_unit_id"
    t.index ["unit_id", "kw_value_id"], name: "index_kw_values_units_on_unit_id_and_kw_value_id"
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

  create_table "owners", force: :cascade do |t|
    t.string "name", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.bigint "pm_system_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_owners_on_deleted_at"
    t.index ["pm_system_id"], name: "index_owners_on_pm_system_id"
  end

  create_table "pm_systems", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_pm_systems_on_deleted_at"
  end

  create_table "poi_categories", force: :cascade do |t|
    t.string "name", limit: 128
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_poi_categories_on_deleted_at"
  end

  create_table "pois", force: :cascade do |t|
    t.string "name", limit: 1024
    t.bigint "poi_category_id"
    t.string "street", limit: 1024
    t.string "city", limit: 256
    t.string "state", limit: 128
    t.string "postal", limit: 32
    t.string "country", limit: 64
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.index ["created_by_id"], name: "index_pois_on_created_by_id"
    t.index ["deleted_at"], name: "index_pois_on_deleted_at"
    t.index ["poi_category_id"], name: "index_pois_on_poi_category_id"
  end

  create_table "unit_type_images", force: :cascade do |t|
    t.bigint "unit_type_id"
    t.string "caption", limit: 1024
    t.string "tags", limit: 1024
    t.integer "sort_order", default: 9999
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: true
    t.index ["unit_type_id"], name: "index_unit_type_images_on_unit_type_id"
  end

  create_table "unit_types", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "community_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "flagged_at"
    t.string "flagged_for"
    t.index ["community_id"], name: "index_unit_types_on_community_id"
    t.index ["deleted_at"], name: "index_unit_types_on_deleted_at"
    t.index ["flagged_at"], name: "index_unit_types_on_flagged_at"
    t.index ["flagged_for"], name: "index_unit_types_on_flagged_for"
  end

  create_table "units", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_available", default: false
    t.date "date_available"
    t.decimal "rent_market", precision: 18, scale: 2
    t.bigint "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit_number"
    t.bigint "building_id"
    t.bigint "unit_type_id"
    t.datetime "deleted_at"
    t.datetime "flagged_at"
    t.string "flagged_for"
    t.index ["building_id"], name: "index_units_on_building_id"
    t.index ["deleted_at"], name: "index_units_on_deleted_at"
    t.index ["flagged_at"], name: "index_units_on_flagged_at"
    t.index ["flagged_for"], name: "index_units_on_flagged_for"
    t.index ["listing_id"], name: "index_units_on_listing_id"
    t.index ["unit_type_id"], name: "index_units_on_unit_type_id"
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

  add_foreign_key "account_access_request_communities", "account_access_requests"
  add_foreign_key "account_access_request_communities", "communities"
  add_foreign_key "buildings", "communities"
  add_foreign_key "communities", "owners"
  add_foreign_key "communities", "pm_systems"
  add_foreign_key "community_share_hits", "communities"
  add_foreign_key "kw_attributes", "kw_classes"
  add_foreign_key "kw_classes", "kw_super_classes"
  add_foreign_key "kw_values", "kw_attributes"
  add_foreign_key "owners", "pm_systems"
  add_foreign_key "unit_types", "communities"
end
