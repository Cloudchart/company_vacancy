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

ActiveRecord::Schema.define(version: 20140326110910) do

  create_table "block_identities", primary_key: "uuid", force: true do |t|
    t.string   "block_id",      limit: 36
    t.string   "identity_id",   limit: 36
    t.string   "identity_type"
    t.integer  "position",                 default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "block_identities", ["block_id"], name: "index_block_identities_on_block_id", using: :btree
  add_index "block_identities", ["identity_id", "identity_type"], name: "index_block_identities_on_identity_id_and_identity_type", using: :btree

  create_table "block_images", primary_key: "uuid", force: true do |t|
    t.string   "image",      null: false
    t.text     "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blocks", primary_key: "uuid", force: true do |t|
    t.string   "section",                                  null: false
    t.integer  "position",                 default: 0
    t.string   "owner_id",      limit: 36,                 null: false
    t.string   "owner_type",                               null: false
    t.string   "identity_type",                            null: false
    t.boolean  "is_locked",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blocks", ["owner_id", "owner_type"], name: "index_blocks_on_owner_id_and_owner_type", using: :btree

  create_table "cloud_profile_emails", primary_key: "uuid", force: true do |t|
    t.string   "user_id",    limit: 36
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cloud_profile_emails", ["address"], name: "index_cloud_profile_emails_on_address", using: :btree

  create_table "cloud_profile_social_networks", primary_key: "uuid", force: true do |t|
    t.string   "user_id",      limit: 36
    t.string   "name",                    null: false
    t.string   "provider_id",             null: false
    t.text     "access_token",            null: false
    t.text     "data"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", primary_key: "uuid", force: true do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.text     "sections"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", primary_key: "uuid", force: true do |t|
    t.string   "name",                  null: false
    t.string   "url"
    t.text     "sections"
    t.string   "location"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "company_id", limit: 36
    t.string   "author_id",  limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["author_id"], name: "index_events_on_author_id", using: :btree
  add_index "events", ["company_id"], name: "index_events_on_company_id", using: :btree

  create_table "features", id: false, force: true do |t|
    t.string   "uuid",        limit: 36
    t.string   "name",                   null: false
    t.text     "description"
    t.integer  "votes_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", primary_key: "uuid", force: true do |t|
    t.string   "provider",    null: false
    t.string   "external_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends_users", id: false, force: true do |t|
    t.string "friend_id", limit: 36
    t.string "user_id",   limit: 36
  end

  create_table "images", primary_key: "uuid", force: true do |t|
    t.string   "image",                 null: false
    t.string   "owner_id",   limit: 36, null: false
    t.string   "owner_type",            null: false
    t.text     "meta"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["owner_id", "owner_type"], name: "index_images_on_owner_id_and_owner_type", using: :btree

  create_table "paragraphs", primary_key: "uuid", force: true do |t|
    t.text     "content",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", primary_key: "uuid", force: true do |t|
    t.string   "name",                  null: false
    t.string   "email"
    t.string   "occupation"
    t.string   "phone"
    t.string   "user_id",    limit: 36
    t.string   "company_id", limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["company_id"], name: "index_people_on_company_id", using: :btree
  add_index "people", ["user_id"], name: "index_people_on_user_id", using: :btree

  create_table "tokens", primary_key: "uuid", force: true do |t|
    t.string   "name",                  null: false
    t.text     "data"
    t.string   "owner_id",   limit: 36
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["owner_id", "owner_type"], name: "index_tokens_on_owner_id_and_owner_type", using: :btree

  create_table "users", primary_key: "uuid", force: true do |t|
    t.string   "password_digest",                 null: false
    t.string   "phone"
    t.boolean  "is_admin",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vacancies", primary_key: "uuid", force: true do |t|
    t.string   "name",                   null: false
    t.text     "description"
    t.string   "salary"
    t.string   "location"
    t.string   "company_id",  limit: 36, null: false
    t.text     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vacancies", ["company_id"], name: "index_vacancies_on_company_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_id",        limit: 36, null: false
    t.string   "item_type",                 null: false
    t.string   "event",                     null: false
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at"
  end

  add_index "versions", ["item_id", "item_type"], name: "index_versions_on_item_id_and_item_type", using: :btree

  create_table "votes", primary_key: "uuid", force: true do |t|
    t.string   "source_id",        limit: 36,             null: false
    t.string   "source_type",                             null: false
    t.string   "destination_id",   limit: 36,             null: false
    t.string   "destination_type",                        null: false
    t.integer  "value",                       default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["destination_id", "destination_type"], name: "index_votes_on_destination_id_and_destination_type", using: :btree
  add_index "votes", ["source_id", "destination_id"], name: "index_votes_on_source_id_and_destination_id", unique: true, using: :btree
  add_index "votes", ["source_id", "source_type"], name: "index_votes_on_source_id_and_source_type", using: :btree

end
