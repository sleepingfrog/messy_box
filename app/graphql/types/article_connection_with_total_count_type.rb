module Types
  class ArticleConnectionWithTotalCountType < GraphQL::Types::Relay::BaseConnection
    edge_type(ArticleEdgeType)

    field :total_count, Integer, null: false
    def total_count
      object.total_count
    end
  end
end
