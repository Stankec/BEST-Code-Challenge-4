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

ActiveRecord::Schema.define(version: 20140119103520) do

  create_table "movies", force: true do |t|
    t.string   "title"
    t.integer  "year"
    t.date     "released"
    t.integer  "runtime"
    t.text     "plot"
    t.text     "awards"
    t.string   "poster"
    t.boolean  "isHidden"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "nameFirst"
    t.string   "nameLast"
    t.string   "nameNickname"
    t.string   "loginUsername"
    t.string   "loginPasswordSalt"
    t.string   "loginPasswordHash"
    t.string   "loginAuthToken"
    t.string   "contactEmail"
    t.boolean  "useNickname"
    t.boolean  "isAdmin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
