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

ActiveRecord::Schema.define(version: 20131210153315) do

  create_table "block_items", primary_key: "uuid", force: true do |t|
    t.string   "title",                     null: false
    t.integer  "position"
    t.string   "ownerable_id",   limit: 36, null: false
    t.string   "ownerable_type",            null: false
    t.string   "itemable_id",    limit: 36, null: false
    t.string   "itemable_type",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "block_items", ["itemable_id", "itemable_type"], name: "index_block_items_on_itemable_id_and_itemable_type", using: :btree
  add_index "block_items", ["ownerable_id", "ownerable_type"], name: "index_block_items_on_ownerable_id_and_ownerable_type", using: :btree

  create_table "companies", primary_key: "uuid", force: true do |t|
    t.string   "logo"
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "texts", primary_key: "uuid", force: true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
