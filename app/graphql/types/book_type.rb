module Types
  class BookType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: true
    field :description, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :chapters, [Types::ChapterType], null: true
    field :frames, [Types::FrameType], null: true

    def frames
      Loaders::AssociationLoader.for(Book, :frames).load(object)
    end

    def chapters
      Loaders::AssociationLoader.for(Book, :chapters).load(object)
    end
  end
end
