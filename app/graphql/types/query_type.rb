# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :user_todos, [Types::UserTodoType], null: true
    field :articles, Types::ArticleConnectionWithTotalCountType, null: true, connection: true do
      argument :query, String, required: false
    end

    def user_todos
      context[:current_user]&.todos
    end

    def articles(query: nil)
      query = if query.present?
                {
                  multi_match: {
                    fields: ['title', 'body'],
                    type: 'cross_fields',
                    operator: 'and',
                    query: query,
                  }
                }
              end

      ElasticsearchRepository.new(Article, query)
    end
  end
end
