class CreateFrameSizes < ActiveRecord::Migration[6.0]
  def change
    create_table :frame_sizes do |t|
      t.text :name
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
