class CreateComparisons < ActiveRecord::Migration[6.1]
  def change
    create_table :comparisons do |t|
      t.references :before, null: false, foreign_key: { to_table: :histories }
      t.references :after, null: false, foreign_key: { to_table: :histories }
      t.float :diff

      t.timestamps
    end
  end
end
