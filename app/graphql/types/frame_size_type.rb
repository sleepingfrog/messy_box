# frozen_string_literal: true
module Types
  class FrameSizeType < Types::BaseObject
    field :width, Integer, null: false
    field :height, Integer, null: false
    field :name, String, null: false
  end
end
