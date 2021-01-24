module Types
  class ArticleType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: true
    field :body, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :tags, [Types::TagType], null: true

    def tags
      Loaders::AssociationLoader.for(Article, :tags).load(object)
    end
  end
end
