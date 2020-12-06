# frozen_string_literal: true
# == Schema Information
#
# Table name: user_todos
#
#  id         :bigint           not null, primary key
#  content    :string           not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_todos_on_user_id               (user_id)
#  index_user_todos_on_user_id_and_position  (user_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserTodo < ApplicationRecord
  belongs_to :user

  with_options presence: true do
    validates :content
    validates :position
  end
end
