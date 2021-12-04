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

ActiveRecord::Schema.define(version: 2021_12_04_080044) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "articles_tags", id: false, force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "tag_id"
    t.index ["article_id"], name: "index_articles_tags_on_article_id"
    t.index ["tag_id"], name: "index_articles_tags_on_tag_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "page_count"
    t.integer "page_offset"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id", "position"], name: "index_chapters_on_book_id_and_position", unique: true
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "comparisons", force: :cascade do |t|
    t.bigint "before_id", null: false
    t.bigint "after_id", null: false
    t.float "diff"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["after_id"], name: "index_comparisons_on_after_id"
    t.index ["before_id"], name: "index_comparisons_on_before_id"
  end

  create_table "entries", force: :cascade do |t|
    t.text "url"
    t.integer "wait"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "frame_sizes", force: :cascade do |t|
    t.text "name", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "frames", force: :cascade do |t|
    t.bigint "frame_size_id", null: false
    t.bigint "page_id"
    t.bigint "book_id", null: false
    t.integer "x"
    t.integer "y"
    t.text "text"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_frames_on_book_id"
    t.index ["frame_size_id"], name: "index_frames_on_frame_size_id"
    t.index ["page_id"], name: "index_frames_on_page_id"
  end

  create_table "histories", force: :cascade do |t|
    t.bigint "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_histories_on_entry_id"
  end

  create_table "page_sizes", force: :cascade do |t|
    t.integer "width", null: false
    t.integer "height", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "page_size_id"
    t.index ["chapter_id", "number"], name: "index_pages_on_chapter_id_and_number", unique: true
    t.index ["chapter_id"], name: "index_pages_on_chapter_id"
    t.index ["page_size_id"], name: "index_pages_on_page_size_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_todos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "content", null: false
    t.integer "position", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "position"], name: "index_user_todos_on_user_id_and_position", unique: true
    t.index ["user_id"], name: "index_user_todos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chapters", "books"
  add_foreign_key "comparisons", "histories", column: "after_id"
  add_foreign_key "comparisons", "histories", column: "before_id"
  add_foreign_key "frames", "books"
  add_foreign_key "frames", "frame_sizes"
  add_foreign_key "frames", "pages"
  add_foreign_key "histories", "entries"
  add_foreign_key "pages", "chapters"
  add_foreign_key "user_todos", "users"
end
