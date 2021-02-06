class CreateFrames < ActiveRecord::Migration[6.0]
  def change
    create_table :frames do |t|
      t.references :frame_size, null: false, foreign_key: true
      t.references :page, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :x
      t.integer :y
      t.text :text
      t.string :color

      t.timestamps
    end
  end
end
