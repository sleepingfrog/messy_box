# frozen_string_literal: true
class MessyBoxSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch

  connections.add(ElasticsearchRepository, Connections::ElasticsearchConnection)
end
