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

ActiveRecord::Schema.define(:version => 20160424000644) do

  create_table "agent_extentions", :force => true do |t|
    t.text    "page_config"
    t.string  "agent_identifier"
    t.integer "user_id"
    t.string  "license_id"
    t.string  "first_name"
    t.string  "middle_name"
    t.string  "last_name"
    t.string  "cn_name"
    t.string  "phone"
    t.string  "wechat"
    t.string  "mail"
    t.string  "url"
    t.string  "license_state"
    t.string  "license_year"
    t.text    "description"
    t.string  "photo_url"
    t.string  "status"
    t.string  "city_area"
    t.text    "city_list"
    t.text    "district_list"
    t.string  "source"
    t.string  "source_id"
    t.integer "broker_company_id"
  end

  create_table "agent_requests", :force => true do |t|
    t.integer "from_user"
    t.integer "to_user"
    t.string  "status"
    t.string  "request_type"
    t.integer "request_context_id"
    t.text    "body"
    t.text    "response"
  end

  create_table "agent_reviews", :force => true do |t|
    t.integer  "agent_extention_id"
    t.integer  "poster_id"
    t.integer  "recommendation_rate"
    t.integer  "knowledge_rate"
    t.integer  "expertise_rate"
    t.integer  "responsiveness_rate"
    t.integer  "negotiation_skill_rate"
    t.text     "comment"
    t.string   "source_reviewer"
    t.string   "source"
    t.integer  "source_post_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
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

  create_table "broker_companies", :force => true do |t|
    t.string   "name"
    t.string   "addr"
    t.string   "city"
    t.string   "state"
    t.integer  "zipcode"
    t.string   "country"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cities", :force => true do |t|
    t.string   "name",           :limit => 255
    t.integer  "population"
    t.float    "income"
    t.string   "above_bachelor", :limit => 255
    t.float    "crime"
    t.float    "us_crime"
    t.string   "unemploy",       :limit => 255
    t.string   "state_unemploy", :limit => 255
    t.string   "hispanics",      :limit => 255
    t.string   "asian",          :limit => 255
    t.string   "caucasion",      :limit => 255
    t.string   "black",          :limit => 255
    t.float    "PMI"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "state",          :limit => 255
    t.string   "county",         :limit => 255
  end

  create_table "favorite_homes", :force => true do |t|
    t.integer "home_id"
    t.integer "uid"
  end

  create_table "home_school_assignments", :force => true do |t|
    t.integer "home_id"
    t.integer "school_id"
    t.string  "distance",  :limit => 255
    t.boolean "assigned"
  end

  create_table "homes", :force => true do |t|
    t.string   "addr1",           :limit => 255
    t.string   "addr2",           :limit => 255
    t.string   "city",            :limit => 255
    t.string   "county",          :limit => 255
    t.string   "state",           :limit => 255
    t.integer  "zipcode"
    t.datetime "last_refresh_at"
    t.datetime "created_at"
    t.string   "realtor_link",    :limit => 255
    t.text     "description"
    t.integer  "bed_num"
    t.float    "bath_num"
    t.string   "indoor_size",     :limit => 255
    t.string   "lot_size",        :limit => 255
    t.float    "price"
    t.float    "unit_price"
    t.string   "home_type",       :limit => 255
    t.integer  "year_built"
    t.string   "neighborhood",    :limit => 255
    t.integer  "stores"
    t.string   "status",          :limit => 255
    t.datetime "added_to_site"
    t.string   "home_style",      :limit => 255
    t.string   "redfin_link",     :limit => 255
    t.string   "listing_agent",   :limit => 255
    t.string   "listed_by",       :limit => 255
    t.string   "meejia_type",     :limit => 255
    t.string   "geo_point",       :limit => 255
    t.string   "parcel"
  end

  create_table "homes_cn", :force => true do |t|
    t.text   "description"
    t.text   "short_desc"
    t.string "city",        :limit => 255
    t.string "indoor_size", :limit => 255
    t.string "lot_size",    :limit => 255
    t.string "price",       :limit => 255
    t.string "unit_price",  :limit => 255
    t.string "home_type",   :limit => 255
  end

  create_table "images", :force => true do |t|
    t.string  "image_url", :limit => 255
    t.integer "home_id"
  end

  create_table "medias", :force => true do |t|
    t.integer  "reference_id"
    t.string   "media_id"
    t.string   "media_url"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "receiver_media_id"
    t.string   "reference_type"
  end

  create_table "public_records", :force => true do |t|
    t.string  "source",      :limit => 255
    t.string  "property_id", :limit => 255
    t.string  "file_id",     :limit => 255
    t.integer "home_id"
    t.date    "record_date"
    t.string  "event",       :limit => 255
    t.float   "price"
  end

  create_table "questions", :force => true do |t|
    t.string   "text"
    t.integer  "uid"
    t.integer  "accepted_aid"
    t.string   "open_id"
    t.datetime "created_at"
  end

  create_table "rents", :force => true do |t|
    t.string   "metro",      :limit => 255
    t.string   "state",      :limit => 255
    t.string   "city",       :limit => 255
    t.float    "studio"
    t.float    "one_bed"
    t.float    "two_bed"
    t.float    "three_bed"
    t.float    "four_bed"
    t.float    "five_bed"
    t.float    "six_bed"
    t.date     "reported"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "saved_searches", :force => true do |t|
    t.text    "search_query"
    t.integer "uid"
  end

  create_table "school_images", :force => true do |t|
    t.string   "image_url"
    t.integer  "school_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schools", :force => true do |t|
    t.string   "name",                  :limit => 255
    t.string   "grade",                 :limit => 255
    t.string   "student_teacher_ratio", :limit => 255
    t.float    "rating"
    t.string   "school_type",           :limit => 255
    t.float    "parent_rating"
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.integer  "zipcode"
    t.string   "phone"
    t.string   "url"
    t.string   "mail"
    t.integer  "rank"
    t.string   "founded"
    t.string   "gender_type"
    t.float    "female_pct"
    t.string   "religion"
    t.text     "description"
    t.float    "boarding_pct"
    t.float    "admin_rate"
    t.float    "fee"
    t.integer  "enrolled_student"
    t.string   "name_cn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "geo_point"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :limit => 255
    t.string   "encrypted_password",                    :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "auth_provider_id"
    t.string   "username"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
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
    t.integer  "agent_id"
    t.text     "search"
    t.integer  "user_id"
    t.string   "nickname"
    t.string   "head_img_url"
    t.datetime "last_search"
    t.integer  "search_count"
  end

end
