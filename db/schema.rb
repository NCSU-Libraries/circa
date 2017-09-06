# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170906163509) do

  create_table "access_sessions", force: :cascade do |t|
    t.integer  "item_id",        limit: 4,                null: false
    t.integer  "order_id",       limit: 4
    t.datetime "start_datetime",                          null: false
    t.datetime "end_datetime"
    t.boolean  "active",                   default: true, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "access_sessions", ["item_id"], name: "fk_rails_f75cf1a560", using: :btree
  add_index "access_sessions", ["order_id"], name: "fk_rails_41324cb864", using: :btree

  create_table "course_reserves", force: :cascade do |t|
    t.string   "course_number", limit: 255
    t.string   "course_name",   limit: 255
    t.integer  "order_id",      limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "digital_image_orders", force: :cascade do |t|
    t.integer  "order_id",         limit: 4,     null: false
    t.string   "image_id",         limit: 255,   null: false
    t.text     "detail",           limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "label",            limit: 255
    t.string   "display_uri",      limit: 255
    t.string   "manifest_uri",     limit: 255
    t.text     "requested_images", limit: 65535
  end

  add_index "digital_image_orders", ["image_id"], name: "by_image_id", using: :btree
  add_index "digital_image_orders", ["order_id"], name: "by_order_id", using: :btree

  create_table "enumeration_values", force: :cascade do |t|
    t.integer  "enumeration_id", limit: 4
    t.string   "value",          limit: 255
    t.string   "value_short",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "order",          limit: 4
  end

  add_index "enumeration_values", ["enumeration_id"], name: "index_enumeration_values_on_enumeration_id", using: :btree

  create_table "enumerations", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "item_archivesspace_records", force: :cascade do |t|
    t.integer "item_id",           limit: 4,   null: false
    t.string  "archivesspace_uri", limit: 255, null: false
  end

  add_index "item_archivesspace_records", ["archivesspace_uri"], name: "index_item_archivesspace_records_on_archivesspace_uri", using: :btree
  add_index "item_archivesspace_records", ["item_id"], name: "fk_rails_54d96fd87e", using: :btree

  create_table "item_catalog_records", force: :cascade do |t|
    t.integer  "item_id",           limit: 4,     null: false
    t.string   "catalog_record_id", limit: 255,   null: false
    t.string   "catalog_item_id",   limit: 255,   null: false
    t.text     "catalog_item_data", limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "item_orders", force: :cascade do |t|
    t.integer  "item_id",           limit: 4
    t.integer  "order_id",          limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "archivesspace_uri", limit: 65535
    t.integer  "user_id",           limit: 4
    t.boolean  "active",                          default: false, null: false
  end

  add_index "item_orders", ["item_id"], name: "index_item_orders_on_item_id", using: :btree
  add_index "item_orders", ["order_id"], name: "index_item_orders_on_order_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "resource_title",        limit: 8704
    t.string   "resource_identifier",   limit: 255
    t.string   "resource_uri",          limit: 255
    t.string   "container",             limit: 255
    t.string   "uri",                   limit: 255
    t.integer  "permanent_location_id", limit: 4
    t.integer  "current_location_id",   limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "barcode",               limit: 255
    t.boolean  "digital_object",                      default: false, null: false
    t.boolean  "unprocessed",                         default: false, null: false
    t.text     "digital_object_title",  limit: 65535
    t.boolean  "obsolete"
  end

  add_index "items", ["current_location_id"], name: "index_items_on_current_location_id", using: :btree
  add_index "items", ["permanent_location_id"], name: "index_items_on_permanent_location_id", using: :btree
  add_index "items", ["resource_identifier"], name: "index_items_on_resource_identifier", using: :btree
  add_index "items", ["resource_uri"], name: "index_items_on_resource_uri", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "uri",               limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "source_id",         limit: 4
    t.boolean  "default",                         default: false, null: false
    t.string   "catalog_item_id",   limit: 255
    t.text     "catalog_item_data", limit: 65535
    t.text     "notes",             limit: 65535
    t.string   "facility",          limit: 255
  end

  add_index "locations", ["uri"], name: "index_locations_on_uri", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "noted_id",   limit: 4
    t.string   "noted_type", limit: 255
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "notes", ["noted_type", "noted_id"], name: "index_notes_on_noted_type_and_noted_id", using: :btree

  create_table "order_assignments", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "order_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "order_assignments", ["order_id"], name: "index_order_assignments_on_order_id", using: :btree
  add_index "order_assignments", ["user_id"], name: "index_order_assignments_on_user_id", using: :btree

  create_table "order_fees", force: :cascade do |t|
    t.integer  "record_id",     limit: 4
    t.string   "record_type",   limit: 255
    t.decimal  "per_unit_fee",                precision: 7, scale: 2
    t.decimal  "per_order_fee",               precision: 7, scale: 2
    t.text     "note",          limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "order_sub_types", force: :cascade do |t|
    t.string   "name",          limit: 255, null: false
    t.string   "label",         limit: 255, null: false
    t.integer  "order_type_id", limit: 4,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "order_sub_types", ["order_type_id"], name: "fk_rails_db7b89e182", using: :btree

  create_table "order_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "label",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "order_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "order_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.boolean  "primary"
  end

  add_index "order_users", ["order_id"], name: "index_order_users_on_order_id", using: :btree
  add_index "order_users", ["user_id"], name: "index_order_users_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.date     "access_date_start"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "open",                        default: true,  null: false
    t.boolean  "confirmed",                   default: false, null: false
    t.integer  "location_id",       limit: 4
    t.date     "access_date_end"
    t.boolean  "deleted",                     default: false, null: false
    t.integer  "order_sub_type_id", limit: 4
    t.integer  "order_type_id_old", limit: 4
  end

  add_index "orders", ["location_id"], name: "fk_rails_5b9551c291", using: :btree

  create_table "reproduction_formats", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.decimal  "default_unit_fee",             precision: 7, scale: 2
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "reproduction_specs", force: :cascade do |t|
    t.integer  "item_order_id",          limit: 4
    t.text     "detail",                 limit: 65535
    t.integer  "pages",                  limit: 4
    t.integer  "reproduction_format_id", limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "state_transitions", force: :cascade do |t|
    t.integer  "record_id",   limit: 4,     null: false
    t.string   "record_type", limit: 255,   null: false
    t.string   "to_state",    limit: 255,   null: false
    t.string   "from_state",  limit: 255
    t.boolean  "current"
    t.integer  "user_id",     limit: 4
    t.text     "metadata",    limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "order_id",    limit: 4
    t.integer  "location_id", limit: 4
  end

  add_index "state_transitions", ["record_id"], name: "index_state_transitions_on_record_id", using: :btree
  add_index "state_transitions", ["record_type"], name: "index_state_transitions_on_record_type", using: :btree
  add_index "state_transitions", ["to_state"], name: "index_state_transitions_on_to_state", using: :btree

  create_table "user_access_sessions", force: :cascade do |t|
    t.integer  "access_session_id", limit: 4, null: false
    t.integer  "user_id",           limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "user_access_sessions", ["access_session_id"], name: "fk_rails_c76e0ec5ff", using: :btree
  add_index "user_access_sessions", ["user_id"], name: "fk_rails_7838ae636f", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "level",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "unity_id",               limit: 255
    t.string   "position",               limit: 255
    t.string   "affiliation",            limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "display_name",           limit: 255
    t.string   "address1",               limit: 255
    t.string   "address2",               limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 255
    t.string   "zip",                    limit: 255
    t.string   "country",                limit: 255
    t.string   "phone",                  limit: 255
    t.datetime "agreement_confirmed_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "patron_type_id",         limit: 4
    t.string   "role_old",               limit: 255
    t.integer  "user_role_id",           limit: 4
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",        limit: 255,        null: false
    t.integer  "item_id",          limit: 4,          null: false
    t.string   "event",            limit: 255,        null: false
    t.string   "whodunnit",        limit: 255
    t.text     "object",           limit: 4294967295
    t.datetime "created_at"
    t.text     "association_data", limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

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
