class CreateFrameSizes < ActiveRecord::Migration[6.0]
  def change
    create_table :frame_sizes do |t|
      t.text :name, null: false
      t.integer :width, null: false
      t.integer :height, null: false

      t.timestamps
    end
  end
end
