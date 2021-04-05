import React from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, useQuery, gql  } from '@apollo/client';

const BOOKS_QUERY = gql`
  query BookConnection($first: Int, $cursor: String) {
    books(first: $first, after: $cursor) {
      nodes {
        id
        title
      }
      pageInfo {
        endCursor
        hasNextPage
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
  const { loading, error, data, fetchMore } = useQuery(BOOKS_QUERY, {
    variables: { first: 10 },
  });

  const onFetchMore = (e) => {
    if (data.books.pageInfo.hasNextPage) {
      fetchMore({
        variables: {
          cursor: data.books.pageInfo.endCursor,
        },
        updateQuery: (prev, { fetchMoreResult }) => {
          if (!fetchMoreResult) { return prev; }

          return({
            ...fetchMoreResult,
            books: {
              ...fetchMoreResult.books,
              nodes: [
                ...prev.books.nodes,
                ...fetchMoreResult.books.nodes,
              ]
            }
          })
        }
      })
    }
  }

  if(loading) { return( <div> loading... </div> ) }
  if(error) { return( <div> error </div> ) }

  return(
    <ul>
      {
        data.books.nodes.map(({id, title}) => (
          <li key={id}>
            <a href={"books/" + id}> {id} : {title}</a>
          </li>
        ))
      }
      <li>
        <button type='button' onClick={onFetchMore} >fetch more</button>
      </li>
    </ul>
  )

}
export default () => {
  return(
    <Provider>
      <BookList />
    </Provider>
  )
}
