module Types
  class ChapterType < Types::BaseObject
    field :id, ID, null: false
    field :page_count, Integer, null: false
    field :page_offset, Integer, null: false
    field :position, Integer, null: false
    field :pages, [Types::PageType], null: true

    def pages
      Loaders::AssociationLoader.for(Chapter, :pages).load(object)
    end
  end
end
