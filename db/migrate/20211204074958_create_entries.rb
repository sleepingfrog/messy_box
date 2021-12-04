class CreateEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :entries do |t|
      t.text :url
      t.integer :wait

      t.timestamps
    end
  end
end
