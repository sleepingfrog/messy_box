require 'test_helper'

class GraphqlQueryUserTodoTypeTest < ActiveSupport::TestCase
  test 'todos' do
    query = <<~QUERY
      query {
        userTodos {
          id
          content
          position
        }
      }
    QUERY
    user = create(:user, :with_todos)
    another_user = create(:user, :with_todos)

    result = MessyBoxSchema.execute(query, context: {current_user: user})
    assert_equal user.todos[0].id.to_s,  result.dig('data', 'userTodos', 0, 'id')
    assert_equal user.todos[1].id.to_s,  result.dig('data', 'userTodos', 1, 'id')
    assert_equal user.todos[0].position, result.dig('data', 'userTodos', 0, 'position')
    assert_equal user.todos[1].position, result.dig('data', 'userTodos', 1, 'position')
    assert_equal user.todos.count,       result.dig('data', 'userTodos').size
  end
end
