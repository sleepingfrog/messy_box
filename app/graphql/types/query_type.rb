# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :user_todos, [Types::UserTodoType], null: true
    field :articles, Types::ArticleConnectionWithTotalCountType, null: true, connection: true do
      argument :query, Types::ArticleQueryType, required: false
    end

    def user_todos
      context[:current_user]&.todos
    end

    def articles(query: nil)
      value_query = if query&.value.present?
                {
                  multi_match: {
                    fields: ['title', 'body'],
                    type: 'cross_fields',
                    operator: 'and',
                    query: query.value,
                  }
                }
              end

      tags_query = if query&.tags.present?
                     {
                       terms: {
                         'tags.name': query.tags
                       }
                     }
                   end

      query = {
        bool: {
          must: [value_query, tags_query].compact
        }
      }

      ElasticsearchRepository.new(Article, query)
    end
  end
end
