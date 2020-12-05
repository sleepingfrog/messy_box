module Mutations
  class DeleteTodo < BaseMutation
    field :status, String, null: false
    field :errors, [String], null: true

    argument :id, ID, required: true

    def resolve(id:)
      todo = context[:current_user].todos.find(id)

      if todo.destroy
        { status: 'success', errors: []}
      else
        { status: 'failure', errors: todo.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound => e
      { status: 'failure', errors: ['not found'] }
    end

    def self.authorized?(object, context)
      super && context[:current_user].present?
    end
  end
end
