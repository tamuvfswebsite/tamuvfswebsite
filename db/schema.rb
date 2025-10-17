# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 20_251_016_103_200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'admins', force: :cascade do |t|
    t.string 'email', null: false
    t.string 'full_name'
    t.string 'uid'
    t.string 'avatar_url'
    t.datetime 'created_at', precision: nil, null: false
    t.datetime 'updated_at', precision: nil, null: false
    t.index ['email'], name: 'index_admins_on_email', unique: true
  end

  create_table 'attendances', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'event_id', null: false
    t.datetime 'checked_in_at', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['event_id'], name: 'index_attendances_on_event_id'
    t.index %w[user_id event_id], name: 'index_attendances_on_user_id_and_event_id', unique: true
    t.index ['user_id'], name: 'index_attendances_on_user_id'
  end

  create_table 'event_rsvps', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.bigint 'event_id', null: false
    t.bigint 'user_id', null: false
    t.string 'status', default: 'yes', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[event_id user_id], name: 'index_event_rsvps_on_event_id_and_user_id', unique: true
    t.index ['event_id'], name: 'index_event_rsvps_on_event_id'
    t.index ['user_id'], name: 'index_event_rsvps_on_user_id'
  end

  create_table 'events', force: :cascade do |t|
    t.string 'title'
    t.text 'description'
    t.datetime 'event_date'
    t.string 'location'
    t.integer 'capacity'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'attendance_points', default: 1, null: false
    t.boolean 'is_published', default: true, null: false
  end

  create_table 'organizational_role_users', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'organizational_role_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['organizational_role_id'], name: 'index_organizational_role_users_on_organizational_role_id'
    t.index %w[user_id organizational_role_id], name: 'index_org_role_users_on_user_and_role', unique: true
    t.index ['user_id'], name: 'index_organizational_role_users_on_user_id'
  end

  create_table 'organizational_roles', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_organizational_roles_on_name', unique: true
  end

  create_table 'resumes', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.float 'gpa'
    t.integer 'graduation_date'
    t.string 'major'
    t.string 'organizational_role'
    t.index ['user_id'], name: 'index_resumes_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'first_name'
    t.string 'last_name'
    t.string 'email'
    t.string 'role'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'google_uid'
    t.string 'google_avatar_url'
    t.integer 'points', default: 0, null: false
    t.index ['google_uid'], name: 'index_users_on_google_uid', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'attendances', 'events'
  add_foreign_key 'attendances', 'users'
  add_foreign_key 'event_rsvps', 'events'
  add_foreign_key 'event_rsvps', 'users'
  add_foreign_key 'organizational_role_users', 'organizational_roles'
  add_foreign_key 'organizational_role_users', 'users'
  add_foreign_key 'resumes', 'users'
end
