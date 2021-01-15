# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :user_todos, [Types::UserTodoType], null: true
    field :articles, Types::ArticleType.connection_type, null: true

    def user_todos
      context[:current_user]&.todos
    end

    def articles
      ElasticsearchRepository.new(Article)
    end
  end
end
