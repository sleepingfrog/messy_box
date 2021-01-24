# frozen_string_literal: true
module Types
  class ArticleQueryType < Types::BaseInputObject
    argument :value, String, required: false
    argument :tags, [String], required: false
  end
end
