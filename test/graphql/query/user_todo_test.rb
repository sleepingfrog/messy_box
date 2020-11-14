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

    result = MessyBoxSchema.execute(query, context: {current_user: User.find(user.id)})
    assert_equal user.todos[0].id.to_s,  result.dig('data', 'userTodos', 0, 'id')
    assert_equal user.todos[1].id.to_s,  result.dig('data', 'userTodos', 1, 'id')
    assert_equal user.todos[0].position, result.dig('data', 'userTodos', 0, 'position')
    assert_equal user.todos[1].position, result.dig('data', 'userTodos', 1, 'position')
    assert_equal user.todos.count,       result.dig('data', 'userTodos').size
  end

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
    user.todos << build(:user_todo, position: 3)
    user.todos << build(:user_todo, position: 1)
    user.todos << build(:user_todo, position: 2)
    user.save!

    result = MessyBoxSchema.execute(query, context: {current_user: User.find(user.id)})
    resuld_todo_positions = result.dig('data', 'userTodos').map{ |todo| todo['position'] }

    assert_equal resuld_todo_positions.sort, resuld_todo_positions
  end
end
