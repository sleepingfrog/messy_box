# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :user_todos, [Types::UserTodoType], null: true

    def user_todos
      context[:current_user]&.todos
    end
  end
end
