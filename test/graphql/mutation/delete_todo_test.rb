require 'test_helper'

class GraphqlMutationDeleteTodoTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, :with_todos)
    @query = <<~QUERY
      mutation deleteTodo($input: DeleteTodoInput!){
        deleteTodo(input: $input) {
          status
          errors
        }
      }
    QUERY
  end

  test 'delete todo' do
    variables = { input: { id: @user.todos.first.id.to_s } }
    result = nil

    assert_difference('UserTodo.count', -1) do
      assert_difference('@user.todos.count', -1) do
        result = MessyBoxSchema.execute(@query, context: { current_user: User.find(@user.id) }, variables: variables)
      end
    end

    assert_equal 'success', result.dig('data', 'deleteTodo', 'status')
  end

  test 'another_user todo' do
    another_user = create(:user, :with_todos)
    variables = { input: { id: another_user.todos.first.id.to_s } }
    result = nil

    assert_no_difference('UserTodo.count') do
      assert_no_difference('@user.todos.count') do
        result = MessyBoxSchema.execute(@query, context: { current_user: User.find(@user.id) }, variables: variables)
      end
    end

    assert_equal 'failure', result.dig('data', 'deleteTodo', 'status')
    assert result.dig('data', 'deleteTodo', 'errors').include?('not found')
  end
end
