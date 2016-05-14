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

ActiveRecord::Schema.define(version: 20150421044102) do

  create_table "investigations", force: :cascade do |t|
    t.string   "name",               limit: 255,                   null: false
    t.text     "jira_search_query",  limit: 65535,                 null: false
    t.text     "investigation_path", limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "update_status",      limit: 1,     default: false, null: false
  end

  create_table "issues", force: :cascade do |t|
    t.integer  "investigation_id",          limit: 4,   null: false
    t.string   "ticket_number",             limit: 255, null: false
    t.integer  "utility_id",                limit: 4,   null: false
    t.integer  "investigation_path_status", limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "issues", ["investigation_id"], name: "index_issues_on_investigation_id", using: :btree
  add_index "issues", ["utility_id"], name: "index_issues_on_utility_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "email",              limit: 255
    t.integer  "sign_in_count",      limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip", limit: 255
    t.string   "last_sign_in_ip",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",           limit: 255
    t.string   "encrypted_password", limit: 255
    t.string   "jira_access_token",  limit: 255
    t.string   "jira_access_key",    limit: 255
    t.string   "toggl_token",        limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "utilities", force: :cascade do |t|
    t.string   "code",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
