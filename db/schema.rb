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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20151211071636) do

  create_table "addresses", :force => true do |t|
    t.string  "addr1"
    t.string  "addr2"
    t.string  "city"
    t.string  "county"
    t.string  "state"
    t.integer "zipcode"
    t.integer "entity_id"
  end

  create_table "agent_extentions", :force => true do |t|
    t.text    "page_config"
    t.string  "agent_identifier"
    t.integer "user_id"
    t.string  "license_id"
  end

  create_table "agent_requests", :force => true do |t|
    t.string "open_id"
    t.string "agent_identifier_list"
    t.string "status"
    t.string "selected_agent"
    t.string "region"
  end

  create_table "answers", :force => true do |t|
    t.integer "uid"
    t.integer "qid"
    t.string  "body"
  end

  create_table "auth_provider", :force => true do |t|
    t.string "name"
    t.string "access_token"
    t.string "access_token_secret"
    t.string "external_id"
  end

  create_table "favorite_homes", :force => true do |t|
    t.integer "home_id"
    t.integer "uid"
  end

  create_table "home_school_assignments", :force => true do |t|
    t.integer "home_id"
    t.integer "school_id"
    t.float   "distance"
    t.boolean "assigned"
  end

  create_table "homes", :force => true do |t|
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.integer  "zipcode"
    t.datetime "last_refresh_at"
    t.datetime "created_at"
    t.string   "link"
    t.text     "description"
    t.integer  "bed_num"
    t.integer  "bath_num"
    t.string   "indoor_size"
    t.string   "lot_size"
    t.float    "price"
    t.float    "unit_price"
    t.string   "home_type"
    t.integer  "year_built"
    t.string   "neighborhood"
    t.integer  "stores"
    t.string   "status"
  end

  create_table "homes_cn", :force => true do |t|
    t.text   "description"
    t.text   "short_desc"
    t.string "city"
    t.string "indoor_size"
    t.string "lot_size"
    t.string "price"
    t.string "unit_price"
    t.string "home_type"
  end

  create_table "images", :force => true do |t|
    t.string  "image_url"
    t.integer "home_id"
  end

  create_table "public_records", :force => true do |t|
    t.string  "source"
    t.string  "property_id"
    t.string  "file_id"
    t.integer "home_id"
  end

  create_table "questions", :force => true do |t|
    t.string   "text"
    t.integer  "uid"
    t.integer  "accepted_aid"
    t.string   "open_id"
    t.datetime "created_at"
  end

  create_table "saved_searches", :force => true do |t|
    t.string  "search_query"
    t.integer "uid"
  end

  create_table "schools", :force => true do |t|
    t.string  "name"
    t.string  "grade"
    t.float   "student_teacher_ratio"
    t.float   "rating"
    t.string  "school_type"
    t.integer "address_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "auth_provider_id"
    t.string   "username"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "qr_code"
    t.integer  "agent_extention_id"
  end

  create_table "wechat_trackings", :force => true do |t|
    t.string  "tracking_type"
    t.integer "wechat_user_id"
    t.text    "item"
  end

  create_table "wechat_users", :force => true do |t|
    t.string   "open_id"
    t.string   "agent_id"
    t.text     "search"
    t.integer  "user_id"
    t.string   "nickname"
    t.string   "head_img_url"
    t.datetime "last_search"
    t.integer  "search_count"
  end

end
