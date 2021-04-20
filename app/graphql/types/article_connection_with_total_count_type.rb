# frozen_string_literal: true
module Types
  class ArticleConnectionWithTotalCountType < GraphQL::Types::Relay::BaseConnection
    edge_type(ArticleEdgeType)

    field :total_count, Integer, null: false
    def total_count
      object.total_count
    end

    class Facet < Types::BaseObject
      field :key, String, null: false
      field :count, Int, null: false
    end

    field :facets, [Facet], null: false

    def facets
      object.facets
    end
  end
end
