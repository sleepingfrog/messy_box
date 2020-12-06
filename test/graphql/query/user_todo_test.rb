# frozen_string_literal: true
require 'test_helper'

class GraphqlQueryUserTodoTypeTest < ActiveSupport::TestCase
  test 'todos must sorted by position' do
    query = <<~QUERY
      query {
        userTodos {
          id
          content
          position
        }
      }
    QUERY
    user = build(:user)
    user.todos << build(:user_todo, content: 'todo1', position: 3)
    user.todos << build(:user_todo, content: 'todo2', position: 1)
    user.todos << build(:user_todo, content: 'todo3', position: 2)
    user.save!

    result = MessyBoxSchema.execute(query, context: { current_user: User.find(user.id) })
    result_todos = result.dig('data', 'userTodos')
    user_todos   = user.todos.sort { |a, b| b.position <=> a.position }

    assert_equal user_todos.map(&:position), result_todos.map { |todo| todo['position'] }
    assert_equal user_todos[0].id.to_s,      result_todos.dig(0, 'id')
    assert_equal user_todos[1].id.to_s,      result_todos.dig(1, 'id')
    assert_equal user_todos[0].position,     result_todos.dig(0, 'position')
    assert_equal user_todos[1].position,     result_todos.dig(1, 'position')
    assert_equal user_todos.count,           result_todos.size
  end
end
