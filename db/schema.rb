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

ActiveRecord::Schema.define(version: 20131218112039) do

  create_table "blocks", primary_key: "uuid", force: true do |t|
    t.string   "kind",                      null: false
    t.integer  "position",                  null: false
    t.string   "owner_id",       limit: 36, null: false
    t.string   "owner_type",                null: false
    t.string   "blockable_id",   limit: 36, null: false
    t.string   "blockable_type",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blocks", ["blockable_id", "blockable_type"], name: "index_blocks_on_blockable_id_and_blockable_type", using: :btree
  add_index "blocks", ["owner_id", "owner_type"], name: "index_blocks_on_owner_id_and_owner_type", using: :btree

  create_table "companies", primary_key: "uuid", force: true do |t|
    t.string   "logo"
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", primary_key: "uuid", force: true do |t|
    t.string   "image",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "texts", primary_key: "uuid", force: true do |t|
    t.text     "content",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", primary_key: "uuid", force: true do |t|
    t.string   "name"
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.string   "avatar"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
