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

ActiveRecord::Schema.define(version: 20141010092714) do

  create_table "activities", primary_key: "uuid", force: true do |t|
    t.string   "action",                                null: false
    t.integer  "group_type",                default: 0
    t.string   "user_id",        limit: 36,             null: false
    t.string   "trackable_id",   limit: 36
    t.string   "trackable_type"
    t.string   "source_id",      limit: 36
    t.string   "source_type"
    t.string   "subscriber_id",  limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["source_id", "source_type"], name: "index_activities_on_source_id_and_source_type", using: :btree
  add_index "activities", ["subscriber_id"], name: "index_activities_on_subscriber_id", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

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

  create_table "cloud_blueprint_charts", primary_key: "uuid", force: true do |t|
    t.string   "company_id", limit: 36,                 null: false
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",             default: false
    t.string   "slug"
  end

  add_index "cloud_blueprint_charts", ["slug"], name: "index_cloud_blueprint_charts_on_slug", using: :btree

  create_table "cloud_blueprint_identities", primary_key: "uuid", force: true do |t|
    t.string   "chart_id",      limit: 36,                 null: false
    t.string   "node_id",       limit: 36,                 null: false
    t.string   "identity_id",   limit: 36,                 null: false
    t.string   "identity_type",                            null: false
    t.boolean  "is_primary",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cloud_blueprint_nodes", primary_key: "uuid", force: true do |t|
    t.string   "chart_id",    limit: 36,             null: false
    t.string   "parent_id",   limit: 36
    t.string   "title"
    t.integer  "knots",                  default: 0
    t.integer  "position",               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "color_index",            default: 0
  end

  create_table "cloud_profile_emails", primary_key: "uuid", force: true do |t|
    t.string   "user_id",    limit: 36
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cloud_profile_emails", ["address"], name: "index_cloud_profile_emails_on_address", using: :btree

  create_table "cloud_profile_social_networks", primary_key: "uuid", force: true do |t|
    t.string   "user_id",      limit: 36
    t.string   "name",                                    null: false
    t.string   "provider_id",                             null: false
    t.text     "access_token",                            null: false
    t.text     "data"
    t.boolean  "is_visible",              default: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cloud_profile_social_networks", ["provider_id"], name: "index_cloud_profile_social_networks_on_provider_id", using: :btree
  add_index "cloud_profile_social_networks", ["user_id"], name: "index_cloud_profile_social_networks_on_user_id", using: :btree

  create_table "comments", primary_key: "uuid", force: true do |t|
    t.text     "content"
    t.string   "user_id",          limit: 36, null: false
    t.string   "commentable_id",   limit: 36, null: false
    t.string   "commentable_type",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "companies", primary_key: "uuid", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "sections"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "established_on"
    t.string   "logotype_uid"
    t.boolean  "is_published",   default: false
    t.boolean  "is_public",      default: false
    t.string   "slug"
    t.string   "site_url"
  end

  add_index "companies", ["slug"], name: "index_companies_on_slug", unique: true, using: :btree

  create_table "companies_banned_users", id: false, force: true do |t|
    t.string "company_id", limit: 36, null: false
    t.string "user_id",    limit: 36, null: false
  end

  add_index "companies_banned_users", ["company_id", "user_id"], name: "index_companies_banned_users_on_company_id_and_user_id", unique: true, using: :btree

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

  create_table "favorites", primary_key: "uuid", force: true do |t|
    t.string   "user_id",          limit: 36, null: false
    t.string   "favoritable_id",   limit: 36, null: false
    t.string   "favoritable_type",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["favoritable_id", "favoritable_type"], name: "index_favorites_on_favoritable_id_and_favoritable_type", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

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
    t.string   "full_name",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends_users", id: false, force: true do |t|
    t.string "friend_id", limit: 36, null: false
    t.string "user_id",   limit: 36, null: false
  end

  add_index "friends_users", ["friend_id", "user_id"], name: "index_friends_users_on_friend_id_and_user_id", unique: true, using: :btree

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

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.string   "impressionable_id",   limit: 36
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "pages", primary_key: "uuid", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "paragraphs", primary_key: "uuid", force: true do |t|
    t.text     "content",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_id",   limit: 36
    t.string   "owner_type"
  end

  create_table "people", primary_key: "uuid", force: true do |t|
    t.string   "first_name",                                                      null: false
    t.string   "last_name",                                                       null: false
    t.string   "email"
    t.string   "occupation"
    t.string   "phone"
    t.string   "user_id",       limit: 36
    t.string   "company_id",    limit: 36,                                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "hired_on"
    t.date     "fired_on"
    t.string   "skype"
    t.string   "int_phone"
    t.text     "bio"
    t.date     "birthday"
    t.decimal  "salary",                   precision: 10, scale: 2, default: 0.0
    t.float    "stock_options", limit: 24
    t.string   "avatar_uid"
  end

  add_index "people", ["company_id"], name: "index_people_on_company_id", using: :btree
  add_index "people", ["user_id"], name: "index_people_on_user_id", using: :btree

  create_table "pictures", primary_key: "uuid", force: true do |t|
    t.string   "owner_id",   limit: 36
    t.string   "owner_type"
    t.string   "image_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pictures", ["owner_id", "owner_type"], name: "index_pictures_on_owner_id_and_owner_type", using: :btree

  create_table "roles", primary_key: "uuid", force: true do |t|
    t.string   "value",                 null: false
    t.string   "user_id",    limit: 36, null: false
    t.string   "owner_id",   limit: 36, null: false
    t.string   "owner_type", limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["owner_id", "owner_type"], name: "index_roles_on_owner_id_and_owner_type", using: :btree
  add_index "roles", ["user_id", "owner_id"], name: "index_roles_on_user_id_and_owner_id", unique: true, using: :btree
  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree
  add_index "roles", ["value"], name: "index_roles_on_value", using: :btree

  create_table "subscriptions", primary_key: "uuid", force: true do |t|
    t.string   "user_id",           limit: 36, null: false
    t.string   "subscribable_id",   limit: 36, null: false
    t.string   "subscribable_type",            null: false
    t.integer  "types_mask"
    t.datetime "created_at"
  end

  add_index "subscriptions", ["subscribable_id", "subscribable_type"], name: "index_subscriptions_on_subscribable_id_and_subscribable_type", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "taggings", primary_key: "uuid", force: true do |t|
    t.string   "tag_id",        limit: 36, null: false
    t.string   "taggable_id",   limit: 36, null: false
    t.string   "taggable_type",            null: false
    t.string   "user_id",       limit: 36
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "user_id"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree
  add_index "taggings", ["user_id"], name: "index_taggings_on_user_id", using: :btree

  create_table "tags", primary_key: "uuid", force: true do |t|
    t.string   "name"
    t.integer  "taggings_count", default: 0
    t.boolean  "is_acceptable",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.boolean  "is_admin",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_uid"
  end

  create_table "vacancies", primary_key: "uuid", force: true do |t|
    t.string   "name",                                     null: false
    t.text     "description"
    t.string   "salary"
    t.string   "location"
    t.text     "settings"
    t.text     "sections"
    t.integer  "impressions_count",            default: 0
    t.string   "company_id",        limit: 36,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author_id",         limit: 36,             null: false
    t.string   "status",                                   null: false
  end

  add_index "vacancies", ["company_id"], name: "index_vacancies_on_company_id", using: :btree
  add_index "vacancies", ["status"], name: "index_vacancies_on_status", using: :btree

  create_table "vacancy_responses", primary_key: "uuid", force: true do |t|
    t.text     "content"
    t.string   "user_id",     limit: 36, null: false
    t.string   "vacancy_id",  limit: 36, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_total"
    t.string   "status",                 null: false
  end

  add_index "vacancy_responses", ["status"], name: "index_vacancy_responses_on_status", using: :btree
  add_index "vacancy_responses", ["user_id", "vacancy_id"], name: "index_vacancy_responses_on_user_id_and_vacancy_id", unique: true, using: :btree

  create_table "vacancy_reviewers", id: false, force: true do |t|
    t.string "person_id",  limit: 36, null: false
    t.string "vacancy_id", limit: 36, null: false
  end

  add_index "vacancy_reviewers", ["person_id", "vacancy_id"], name: "index_vacancy_reviewers_on_person_id_and_vacancy_id", unique: true, using: :btree

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
