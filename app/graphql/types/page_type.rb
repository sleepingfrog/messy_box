module Types
  class PageType < Types::BaseObject
    field :number, Integer, null: false
    field :frames, [Types::FrameType], null: false
    field :page_size, Types::PageSizeType, null: false

    def page_size
      Loaders::AssociationLoader.for(Page, :page_size).load(object)
    end

    def frames
      Loaders::AssociationLoader.for(Page, :frames).load(object)
    end
  end
end
