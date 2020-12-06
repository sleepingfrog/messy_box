require 'test_helper'

class GraphqlMutationCreateTodoTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, :with_todos)
    @query = <<~QUERY
       mutation createTodo($input: CreateTodoInput!){
         createTodo(input: $input){
           todo {
             id
             content
             position
           }
           errors
         }
      }
    QUERY
  end

  test 'valid variables' do
    variables = { input: { content: 'todo string' } }
    result = nil

    assert_difference('UserTodo.count', 1) do
      assert_difference('@user.todos.count', 1) do
        result = MessyBoxSchema.execute(@query, context: { current_user: User.find(@user.id) }, variables: variables)
      end
    end

    assert_equal variables.dig(:input, :content), result.dig('data', 'createTodo', 'todo', 'content')
  end

  test 'content blank' do
    variables = { input: { content: '' } }
    result = nil

    assert_no_difference('UserTodo.count') do
      assert_no_difference('@user.todos.count') do
        result = MessyBoxSchema.execute(@query, context: { current_user: User.find(@user.id) }, variables: variables)
      end
    end

    assert result.dig('data', 'createTodo', 'errors').present?
  end
end
