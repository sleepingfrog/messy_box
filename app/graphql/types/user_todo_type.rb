module Types
  class UserTodoType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :content, String, null: false
    field :position, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def self.authorized?(object, context)
      super && context[:current_user].present?
    end
  end
end
