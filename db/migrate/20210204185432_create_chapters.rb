class CreateChapters < ActiveRecord::Migration[6.0]
  def change
    create_table :chapters do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :page_count
      t.integer :page_offset
      t.integer :position

      t.timestamps

      t.index [:book_id, :position], unique: true
    end
  end
end
