import React from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, Query } from 'react-apollo';
import { TodoQuery } from './query.gql'

const Provider = ({ children }) => (
  <ApolloProvider client={createClient(createCache())} >
    {children}
  </ApolloProvider>
)

const TodoList = () => (
  <Query query={TodoQuery}>
  {({ data, loading }) => (
      <div>
        {loading
          ? 'loading...'
          : data.userTodos.map(({ id, content }) => (
              <div key={id}>
                <p>{content}</p>
              </div>
            ))}
      </div>
  )}
  </Query>
)

export default () => {
  return(
    <Provider>
      <TodoList />
    </Provider>
  )
}
