# frozen_string_literal: true
module Types
  class FrameType < Types::BaseObject
    field :id, ID, null: false
    field :color, String, null: true
    field :text, String, null: true
    field :x, Integer, null: true
    field :y, Integer, null: true
    field :frame_size, Types::FrameSizeType, null: false

    def frame_size
      Loaders::AssociationLoader.for(Frame, :frame_size).load(object)
    end
  end
end
