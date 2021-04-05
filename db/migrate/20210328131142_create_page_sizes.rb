class CreatePageSizes < ActiveRecord::Migration[6.0]
  def change
    create_table :page_sizes do |t|
      t.integer :width, null: false
      t.integer :height, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
