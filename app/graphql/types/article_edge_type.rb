module Types
  class ArticleEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(ArticleType)
  end
end
