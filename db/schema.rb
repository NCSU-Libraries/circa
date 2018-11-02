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

ActiveRecord::Schema.define(version: 2018_07_17_170822) do

  create_table "access_sessions", id: :integer, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "order_id"
    t.datetime "start_datetime", null: false
    t.datetime "end_datetime"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "fk_rails_f75cf1a560"
    t.index ["order_id"], name: "fk_rails_41324cb864"
  end

  create_table "course_reserves", id: :integer, force: :cascade do |t|
    t.string "course_number"
    t.string "course_name"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "digital_collections_orders", id: :integer, force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "resource_identifier", null: false
    t.text "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_title"
    t.string "display_uri"
    t.string "manifest_uri"
    t.text "requested_images"
    t.text "requested_images_detail"
    t.integer "total_images_in_resource"
    t.index ["order_id"], name: "by_order_id"
    t.index ["resource_identifier"], name: "by_image_id"
  end

  create_table "enumeration_values", id: :integer, force: :cascade do |t|
    t.integer "enumeration_id"
    t.string "value"
    t.string "value_short"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.index ["enumeration_id"], name: "index_enumeration_values_on_enumeration_id"
  end

  create_table "enumerations", id: :integer, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "order_id"
    t.date "invoice_date"
    t.date "payment_date"
    t.text "attn"
    t.string "invoice_id"
    t.text "custom_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_archivesspace_records", id: :integer, force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "archivesspace_uri", null: false
    t.index ["archivesspace_uri"], name: "index_item_archivesspace_records_on_archivesspace_uri"
    t.index ["item_id"], name: "fk_rails_54d96fd87e"
  end

  create_table "item_catalog_records", id: :integer, force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "catalog_record_id", null: false
    t.string "catalog_item_id", null: false
    t.text "catalog_item_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_orders", id: :integer, force: :cascade do |t|
    t.integer "item_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "archivesspace_uri"
    t.integer "user_id"
    t.boolean "active", default: false, null: false
    t.integer "deactivated_by_user_id"
    t.datetime "deactivated_at"
    t.index ["item_id"], name: "index_item_orders_on_item_id"
    t.index ["order_id"], name: "index_item_orders_on_order_id"
  end

  create_table "items", id: :integer, force: :cascade do |t|
    t.string "resource_title", limit: 8704
    t.string "resource_identifier"
    t.string "resource_uri"
    t.string "container"
    t.string "uri"
    t.integer "permanent_location_id"
    t.integer "current_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "barcode"
    t.boolean "digital_object", default: false, null: false
    t.boolean "unprocessed", default: false, null: false
    t.text "digital_object_title"
    t.boolean "obsolete"
    t.string "old_uri"
    t.index ["current_location_id"], name: "index_items_on_current_location_id"
    t.index ["permanent_location_id"], name: "index_items_on_permanent_location_id"
    t.index ["resource_identifier"], name: "index_items_on_resource_identifier"
    t.index ["resource_uri"], name: "index_items_on_resource_uri"
  end

  create_table "locations", id: :integer, force: :cascade do |t|
    t.string "title"
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id"
    t.string "catalog_item_id"
    t.text "catalog_item_data"
    t.text "notes"
    t.string "facility"
    t.index ["uri"], name: "index_locations_on_uri"
  end

  create_table "notes", id: :integer, force: :cascade do |t|
    t.integer "noted_id"
    t.string "noted_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["noted_type", "noted_id"], name: "index_notes_on_noted_type_and_noted_id"
  end

  create_table "order_assignments", id: :integer, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_assignments_on_order_id"
    t.index ["user_id"], name: "index_order_assignments_on_user_id"
  end

  create_table "order_fees", id: :integer, force: :cascade do |t|
    t.integer "record_id"
    t.string "record_type"
    t.decimal "per_unit_fee", precision: 7, scale: 2
    t.decimal "per_order_fee", precision: 7, scale: 2
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit_fee_type"
    t.string "per_order_fee_description"
  end

  create_table "order_sub_types", id: :integer, force: :cascade do |t|
    t.string "name", null: false
    t.string "label", null: false
    t.integer "order_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_location_id"
    t.boolean "default"
    t.index ["order_type_id"], name: "fk_rails_db7b89e182"
  end

  create_table "order_types", id: :integer, force: :cascade do |t|
    t.string "name", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_users", id: :integer, force: :cascade do |t|
    t.integer "user_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "primary"
    t.boolean "remote"
    t.index ["order_id"], name: "index_order_users_on_order_id"
    t.index ["user_id"], name: "index_order_users_on_user_id"
  end

  create_table "orders", id: :integer, force: :cascade do |t|
    t.date "access_date_start"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "open", default: true, null: false
    t.boolean "confirmed", default: false, null: false
    t.integer "location_id"
    t.date "access_date_end"
    t.boolean "deleted", default: false, null: false
    t.integer "order_sub_type_id"
    t.integer "order_type_id_old"
    t.integer "cloned_order_id"
    t.index ["location_id"], name: "fk_rails_5b9551c291"
  end

  create_table "reproduction_formats", id: :integer, force: :cascade do |t|
    t.string "name"
    t.decimal "default_unit_fee_internal", precision: 7, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.decimal "default_unit_fee_external", precision: 7, scale: 2
    t.decimal "default_unit_fee", precision: 7, scale: 2
  end

  create_table "reproduction_specs", id: :integer, force: :cascade do |t|
    t.integer "item_order_id"
    t.text "detail"
    t.integer "pages"
    t.integer "reproduction_format_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "state_transitions", id: :integer, force: :cascade do |t|
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.string "to_state", null: false
    t.string "from_state"
    t.boolean "current"
    t.integer "user_id"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_id"
    t.integer "location_id"
    t.index ["record_id"], name: "index_state_transitions_on_record_id"
    t.index ["record_type"], name: "index_state_transitions_on_record_type"
    t.index ["to_state"], name: "index_state_transitions_on_to_state"
  end

  create_table "user_access_sessions", id: :integer, force: :cascade do |t|
    t.integer "access_session_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_session_id"], name: "fk_rails_c76e0ec5ff"
    t.index ["user_id"], name: "fk_rails_7838ae636f"
  end

  create_table "user_roles", id: :integer, force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unity_id"
    t.string "position"
    t.string "affiliation"
    t.string "first_name"
    t.string "last_name"
    t.string "display_name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "phone"
    t.datetime "agreement_confirmed_at"
    t.string "unconfirmed_email"
    t.integer "researcher_type_id"
    t.string "role_old"
    t.integer "user_role_id"
    t.boolean "inactive"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :integer, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.text "association_data"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "access_sessions", "items"
  add_foreign_key "access_sessions", "orders"
  add_foreign_key "enumeration_values", "enumerations"
  add_foreign_key "item_archivesspace_records", "items"
  add_foreign_key "item_orders", "items"
  add_foreign_key "item_orders", "orders"
  add_foreign_key "items", "locations", column: "current_location_id"
  add_foreign_key "items", "locations", column: "permanent_location_id"
  add_foreign_key "order_sub_types", "order_types"
  add_foreign_key "order_users", "users"
  add_foreign_key "orders", "locations"
  add_foreign_key "user_access_sessions", "access_sessions"
  add_foreign_key "user_access_sessions", "users"
end
