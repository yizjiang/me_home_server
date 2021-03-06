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

ActiveRecord::Schema.define(:version => 20161215085338) do

  create_table "agent_articles", :force => true do |t|
    t.string   "media_id"
    t.text     "content"
    t.string   "url"
    t.string   "title"
    t.string   "digest"
    t.string   "author"
    t.string   "content_source_url"
    t.integer  "user_id"
    t.string   "thumb_media_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

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
    t.string  "license_issue"
    t.text    "description"
    t.string  "photo_url"
    t.string  "status"
    t.string  "city_area"
    t.text    "city_list"
    t.text    "district_list"
    t.string  "source"
    t.string  "source_id"
    t.integer "broker_company_id"
    t.string  "license_type"
    t.date    "license_expire"
    t.string  "mailing_address"
    t.string  "title"
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

  create_table "articles", :force => true do |t|
    t.string   "media_id"
    t.text     "content"
    t.string   "url"
    t.string   "title"
    t.string   "digest"
    t.string   "author"
    t.string   "content_source_url"
    t.integer  "user_id"
    t.string   "thumb_media_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
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
    t.string   "license_id"
    t.string   "url"
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
    t.string   "geo_point"
  end

  create_table "commercial_images", :force => true do |t|
    t.string   "image_url"
    t.integer  "commercial_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "commercials", :force => true do |t|
    t.string   "sale_type"
    t.string   "category"
    t.string   "status"
    t.string   "name"
    t.integer  "rating"
    t.float    "size"
    t.float    "price"
    t.float    "price_sf"
    t.float    "cap_rate"
    t.datetime "on_market"
    t.datetime "last_updated"
    t.integer  "num_of_properties"
    t.string   "land_size"
    t.string   "property_type"
    t.string   "addr1"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.integer  "zipcode"
    t.string   "geo_point"
    t.integer  "year_b_r"
    t.string   "submarket"
    t.string   "market"
    t.integer  "stories"
    t.string   "broker_company_id"
    t.string   "agent_extention_id"
    t.string   "source_id"
    t.string   "costar_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorite_homes", :force => true do |t|
    t.integer "home_id"
    t.integer "uid"
  end

  create_table "home_school_assignments", :force => true do |t|
    t.integer "home_id"
    t.integer "school_id"
    t.string  "distance"
    t.boolean "assigned"
  end

  add_index "home_school_assignments", ["home_id"], :name => "index_home_school_assignments_on_home_id"

  create_table "home_taxes", :force => true do |t|
    t.string   "year"
    t.float    "taxes"
    t.float    "land_value"
    t.float    "added_value"
    t.integer  "home_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "homes", :force => true do |t|
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "zipcode"
    t.datetime "last_refresh_at"
    t.datetime "created_at"
    t.string   "realtor_link"
    t.text     "description"
    t.integer  "bed_num"
    t.float    "bath_num"
    t.string   "indoor_size"
    t.string   "lot_size"
    t.float    "price"
    t.float    "unit_price"
    t.string   "home_type"
    t.integer  "year_built"
    t.string   "neighborhood"
    t.integer  "stores"
    t.string   "status"
    t.datetime "added_to_site"
    t.string   "home_style"
    t.string   "redfin_link"
    t.string   "listing_agent"
    t.string   "listed_by"
    t.string   "meejia_type"
    t.string   "geo_point"
    t.string   "parcel"
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
    t.string  "image_url", :limit => 255
    t.integer "home_id"
  end

  add_index "images", ["home_id"], :name => "index_images_on_home_id"

  create_table "listing_homes", :force => true do |t|
    t.integer "home_id"
    t.integer "user_id"
    t.string  "status"
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

  create_table "metric_home_trackings", :force => true do |t|
    t.integer  "uid"
    t.integer  "hid"
    t.string   "source"
    t.string   "status"
    t.integer  "viewed_time"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "metric_home_trackings", ["hid"], :name => "index_metric_home_trackings_on_hid"
  add_index "metric_home_trackings", ["source"], :name => "index_metric_home_trackings_on_source"
  add_index "metric_home_trackings", ["status"], :name => "index_metric_home_trackings_on_status"
  add_index "metric_home_trackings", ["uid"], :name => "index_metric_home_trackings_on_uid"
  add_index "metric_home_trackings", ["viewed_time"], :name => "index_metric_home_trackings_on_viewed_time"

  create_table "properties", :force => true do |t|
    t.string   "property_type"
    t.string   "addr1"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.integer  "zipcode"
    t.integer  "rating"
    t.float    "land_size"
    t.string   "land_parcel"
    t.string   "land_zoning"
    t.string   "land_use"
    t.string   "building_desc"
    t.float    "building_size"
    t.integer  "year_built"
    t.integer  "year_renovated"
    t.integer  "building_stories"
    t.string   "building_class"
    t.string   "building_tenancy"
    t.string   "building_parking"
    t.string   "building_elevator"
    t.string   "geo_point"
    t.string   "sale_property_id"
    t.string   "source_id"
    t.string   "costar_link"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "name"
    t.string   "grade"
    t.string   "student_teacher_ratio"
    t.float    "rating"
    t.string   "school_type"
    t.float    "parent_rating"
    t.string   "addr1"
    t.string   "addr2"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "zipcode"
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
    t.string   "qrcode"
  end

end
