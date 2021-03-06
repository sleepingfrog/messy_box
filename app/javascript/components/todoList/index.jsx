import React, { useState } from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, Query, Mutation } from 'react-apollo';
import { TodoQuery, AddTodo, DeleteTodo } from './query.gql'

const Provider = ({ children }) => (
  <ApolloProvider client={createClient(createCache())} >
    {children}
  </ApolloProvider>
)

const TodoForm = ({
  initialContent='',
  loading,
  addTodo
}) => {
  const [content, setContent] = useState(initialContent);
  const onSubmit = (event) => {
    addTodo({content});
    setContent('');
    event.preventDefault();
  }
  return(
    <div>
      <form onSubmit={onSubmit}>
        <input
          type='text'
          placeholder='todo content'
          value={content}
          onChange={e => setContent(e.currentTarget.value)}
        />
        { loading
            ? 'creating..'
            : (
              <button type='submit'>add todo</button>
            )
        }
      </form>
    </div>
  )
}

const AddTodoForm = () => (
  <Mutation mutation={AddTodo}>
    {(addTodo, {loading}) => (
      <TodoForm
        loading={loading}
        addTodo={({content}) =>
          addTodo({
            variables: {
              input: { content }
            },
            update: (cache, { data: { createTodo } }) => {
              const todo = createTodo.todo;
              if (todo) {
                const currentTodos = cache.readQuery({ query: TodoQuery });
                cache.writeQuery({
                  query: TodoQuery,
                  data: {
                    userTodos: [todo, ...currentTodos.userTodos],
                  }
                })
              }
            }
          })
        }
      />
    )}
  </Mutation>
)

const Todo = ({id, content}) => {
  return(
    <Mutation mutation={DeleteTodo}>
    {(deleteTodo, {loading}) => (
      <div>
        <p>
          <span>{content}</span>
          <button onClick={
            e => deleteTodo({
              variables: { input: { id }},
              update: (cache, { data: { deleteTodo } }) => {
                const status = deleteTodo.status;
                if (status === 'success') {
                  const currentTodos = cache.readQuery({ query: TodoQuery });
                  cache.writeQuery({
                    query: TodoQuery,
                    data: {
                      userTodos: currentTodos.userTodos.filter( item => (item.id != id ))
                    }
                  })
                }
              }
            })}
            >x</button>
        </p>
      </div>
    ) }
    </Mutation>
  )
}
const TodoList = () => (
  <Query query={TodoQuery}>
    {({ data, loading}) => (
      <div>
        {loading
          ? 'loading...'
          : data.userTodos.map(({ id, content }) => (
              <Todo key={id} id={id} content={content} />
            ))}
      </div>
      )
    }
  </Query>
)

export default () => {
  return(
    <Provider>
      <AddTodoForm />
      <TodoList />
    </Provider>
  )
}
