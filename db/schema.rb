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

ActiveRecord::Schema.define(version: 20140206121342) do

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

  create_table "blocks", primary_key: "uuid", force: true do |t|
    t.string   "section",                              null: false
    t.integer  "position",                 default: 0
    t.string   "owner_id",      limit: 36,             null: false
    t.string   "owner_type",                           null: false
    t.string   "identity_type",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blocks", ["owner_id", "owner_type"], name: "index_blocks_on_owner_id_and_owner_type", using: :btree

  create_table "companies", primary_key: "uuid", force: true do |t|
    t.string   "name",                   null: false
    t.text     "description"
    t.string   "logo_id",     limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["logo_id"], name: "index_companies_on_logo_id", using: :btree

  create_table "images", primary_key: "uuid", force: true do |t|
    t.string   "image",      null: false
    t.text     "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paragraphs", primary_key: "uuid", force: true do |t|
    t.text     "content",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", primary_key: "uuid", force: true do |t|
    t.string   "name",                      null: false
    t.text     "data"
    t.string   "tokenable_id",   limit: 36
    t.string   "tokenable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", primary_key: "uuid", force: true do |t|
    t.string   "name"
    t.string   "email",                      null: false
    t.string   "password_digest",            null: false
    t.string   "avatar_id",       limit: 36
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["avatar_id"], name: "index_users_on_avatar_id", using: :btree

  create_table "vacancies", primary_key: "uuid", force: true do |t|
    t.string   "name",                   null: false
    t.text     "description"
    t.string   "salary"
    t.string   "location"
    t.string   "company_id",  limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "settings"
  end

  add_index "vacancies", ["company_id"], name: "index_vacancies_on_company_id", using: :btree

end
