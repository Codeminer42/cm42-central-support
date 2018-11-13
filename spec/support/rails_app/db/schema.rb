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

ActiveRecord::Schema.define(version: 20181030162426) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id",             null: false
    t.integer  "user_id",                null: false
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "action"
    t.text     "subject_changes"
    t.string   "subject_destroyed_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "user_id"], name: "index_activities_on_project_id_and_user_id", using: :btree
    t.index ["project_id"], name: "index_activities_on_project_id", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "attachinary_files", force: :cascade do |t|
    t.string   "attachinariable_type"
    t.integer  "attachinariable_id"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree
  end

  create_table "enrollments", id: :bigserial, force: :cascade do |t|
    t.integer  "team_id",                    null: false
    t.integer  "user_id",                    null: false
    t.boolean  "is_admin",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id", "user_id"], name: "index_enrollments_on_team_id_and_user_id", unique: true, using: :btree
  end

  create_table "integrations", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id"
    t.string   "kind",       null: false
    t.hstore   "data",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["data"], name: "index_integrations_on_data", using: :gin
  end

  create_table "memberships", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "user_id"], name: "index_memberships_on_project_id_and_user_id", unique: true, using: :btree
    t.index ["project_id"], name: "index_memberships_on_project_id", using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
  end

  create_table "notes", id: :bigserial, force: :cascade do |t|
    t.text     "note"
    t.integer  "user_id"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
  end

  create_table "ownerships", id: :bigserial, force: :cascade do |t|
    t.integer  "team_id",                    null: false
    t.integer  "project_id",                 null: false
    t.boolean  "is_owner",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id", "project_id"], name: "index_ownerships_on_team_id_and_project_id", unique: true, using: :btree
  end

  create_table "projects", id: :bigserial, force: :cascade do |t|
    t.string   "name"
    t.string   "point_scale",         default: "fibonacci"
    t.date     "start_date"
    t.integer  "iteration_start_day", default: 1
    t.integer  "iteration_length",    default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_velocity",    default: 10
    t.string   "slug"
    t.integer  "stories_count",       default: 0
    t.integer  "memberships_count",   default: 0
    t.datetime "archived_at"
    t.index ["slug"], name: "index_projects_on_slug", unique: true, using: :btree
  end

  create_table "stories", id: :bigserial, force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "estimate"
    t.string   "story_type",        default: "feature"
    t.string   "state",             default: "unstarted"
    t.datetime "accepted_at"
    t.integer  "requested_by_id"
    t.integer  "owned_by_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "position"
    t.string   "labels"
    t.string   "requested_by_name"
    t.string   "owned_by_name"
    t.string   "owned_by_initials"
    t.datetime "started_at"
    t.float    "cycle_time",        default: 0.0
    t.datetime "delivered_at"
  end

  create_table "tasks", id: :bigserial, force: :cascade do |t|
    t.integer  "story_id"
    t.string   "name",       limit: 255
    t.boolean  "done",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["story_id"], name: "index_tasks_on_story_id", using: :btree
  end

  create_table "teams", id: :bigserial, force: :cascade do |t|
    t.string   "name",                                          null: false
    t.string   "slug"
    t.string   "logo"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disable_registration",          default: false, null: false
    t.string   "registration_domain_whitelist"
    t.string   "registration_domain_blacklist"
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_teams_on_slug", unique: true, using: :btree
  end

  create_table "users", id: :bigserial, force: :cascade do |t|
    t.string   "email",                              default: "",          null: false
    t.string   "encrypted_password",     limit: 128, default: "",          null: false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "initials"
    t.boolean  "email_delivery",                     default: true
    t.boolean  "email_acceptance",                   default: true
    t.boolean  "email_rejection",                    default: true
    t.datetime "reset_password_sent_at"
    t.string   "locale"
    t.integer  "memberships_count",                  default: 0
    t.string   "username",                                                 null: false
    t.string   "time_zone",                          default: "Brasilia",  null: false
    t.string   "role",                               default: "developer", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "enrollments", "teams", name: "enrollments_team_id_fk", on_delete: :cascade
  add_foreign_key "enrollments", "users", name: "enrollments_user_id_fk", on_delete: :cascade
  add_foreign_key "integrations", "projects", name: "integrations_project_id_fk", on_delete: :cascade
  add_foreign_key "memberships", "projects", name: "memberships_project_id_fk", on_delete: :cascade
  add_foreign_key "memberships", "users", name: "memberships_user_id_fk", on_delete: :cascade
  add_foreign_key "notes", "stories", name: "notes_story_id_fk", on_delete: :cascade
  add_foreign_key "ownerships", "projects", name: "ownerships_project_id_fk", on_delete: :cascade
  add_foreign_key "ownerships", "teams", name: "ownerships_team_id_fk", on_delete: :cascade
  add_foreign_key "stories", "projects", name: "stories_project_id_fk", on_delete: :cascade
end
