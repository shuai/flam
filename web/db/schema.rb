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

ActiveRecord::Schema.define(:version => 20101114003324) do

  create_table "admin_tasks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "status"
    t.string   "err_msg"
    t.integer  "priority"
    t.integer  "raw_video_id"
    t.integer  "bitrate"
    t.string   "location"
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "captions", :force => true do |t|
    t.integer "package_id"
    t.string  "location"
    t.string  "format"
  end

  create_table "clips", :force => true do |t|
    t.integer  "raw_video_id"
    t.string   "location"
    t.integer  "duration"
    t.integer  "bitrate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programs", :force => true do |t|
    t.string   "title"
    t.integer  "length"
    t.integer  "clip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_video_streams", :force => true do |t|
    t.integer "raw_video_id"
    t.integer "index"
    t.string  "codec"
    t.string  "codec_long"
    t.string  "type"
    t.integer "sample_rate"
    t.integer "channels"
    t.integer "bits_per_sample"
    t.integer "avg_framerate"
    t.integer "start_time"
    t.integer "duration"
  end

  create_table "raw_videos", :force => true do |t|
    t.integer "package_id"
    t.string  "location"
    t.integer "bitrate"
    t.string  "title"
    t.string  "format"
    t.integer "duration"
    t.integer "size"
    t.string  "author"
    t.string  "copyright"
    t.string  "comment"
    t.string  "status"
  end

end
