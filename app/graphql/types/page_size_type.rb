# frozen_string_literal: true
module Types
  class PageSizeType < Types::BaseObject
    field :name, String, null: false
    field :width, Integer, null: false
    field :height, Integer, null: false
  end
end
