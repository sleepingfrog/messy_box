class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :number

      t.timestamps

      t.index [:chapter_id, :number], unique: true
    end
  end
end
