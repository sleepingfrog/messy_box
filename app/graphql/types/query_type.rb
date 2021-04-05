# frozen_string_literal: true
module Types
  class QueryType < Types::BaseObject
    field :user_todos, [Types::UserTodoType], null: true
    field :articles, Types::ArticleConnectionWithTotalCountType, null: true, connection: true do
      argument :query, Types::ArticleQueryType, required: false
    end
    field :tags, [Types::TagType], null: false
    field :books, Types::BookType.connection_type, null: true
    field :book, Types::BookType, null: true do
      argument :id, ID, required: true
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

    def tags
      Tag.all
    end

    def books
      Book.all
    end

    def book(id:)
      Book.find(id)
    end
  end
end
