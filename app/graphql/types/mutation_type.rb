# frozen_string_literal: true
module Types
  class MutationType < Types::BaseObject
    field :delete_todo, mutation: Mutations::DeleteTodo
    field :create_todo, mutation: Mutations::CreateTodo
    field :page_allocate, mutation: Mutations::PageAllocate
  end
end
