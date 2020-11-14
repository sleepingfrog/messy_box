class UserTodo < ApplicationRecord
  belongs_to :user

  with_options presence: true do
    validates :content
    validates :position
  end
end
