import React from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, useQuery, gql  } from '@apollo/client';

const BOOKS_QUERY = gql`
  query BookConnection($first: Int) {
    books(first: $first) {
      nodes {
        id
        title
      }
    }
  }
`

const Provider = ({ children }) => (
  <ApolloProvider client={createClient(createCache())}>
    {children}
  </ApolloProvider>
)

const BookList = () => {
  const { loading, error, data } = useQuery(BOOKS_QUERY, {
    variables: { first: 10 }
  });

  if(loading) { return( <div> loading... </div> ) }
  if(error) { return( <div> error </div> ) }
  return(
    <div>
      {
        data.books.nodes.map(({id, title}) => (
          <div key={id}> {id} : {title} </div>
        ))
      }
    </div>
  )

}
export default () => {
  return(
    <Provider>
      <BookList />
    </Provider>
  )
}
