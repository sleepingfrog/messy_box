module Mutations
  class CreateTodo < BaseMutation
    field :todo, Types::UserTodoType, null: true
    field :errors, [String], null: false

    argument :content, String, required: true

    def resolve(content:)
      last_position = context[:current_user].todos.last&.position || 0
      todo = context[:current_user].todos.build(content: content, position: last_position + 1)
      if todo.save
        { todo: todo, errors: [], }
      else
        { todo: nil, errors: todo.errors.full_messages }
      end
    end
  end
end
