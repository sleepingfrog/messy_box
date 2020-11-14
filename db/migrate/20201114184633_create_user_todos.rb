class CreateUserTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :user_todos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :content, null: false
      t.integer :position, null: false

      t.timestamps

      t.index [:user_id, :position], unique: true
    end
  end
end
