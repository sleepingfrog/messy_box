class CreateUserTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :user_todos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :content
      t.integer :position

      t.timestamps
    end
  end
end
