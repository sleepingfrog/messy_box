module Types
  class MutationType < Types::BaseObject
    field :delete_todo, mutation: Mutations::DeleteTodo
    field :create_todo, mutation: Mutations::CreateTodo
  end
end
