module Types
  class PageType < Types::BaseObject
    field :number, Integer, null: false
    field :frames, [Types::FrameType], null: false

    def frames
      Loaders::AssociationLoader.for(Page, :frames).load(object)
    end
  end
end
