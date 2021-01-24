import React, { useState, useEffect } from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, useQuery, gql  } from '@apollo/client';
import Tag from './tag'
import Article from './article'
import Facet from './facet'

const Provider = ({ children }) => (
  <ApolloProvider client={createClient(createCache())}>
    {children}
  </ApolloProvider>
)

const ARTICLE_QUERY = gql`
  query ArticleConnectionWithTotalCount($query: ArticleQuery){
    articles(query: $query) {
      nodes {
        id
        title
        body
        tags {
          name
        }
      }
      totalCount
      facets {
        key
        count
      }
    }
  }
 `;

const ArticleList = () => {
  const [inputText, setInputText] = useState('');
  const [queryText, setQueryText] = useState('');
  const { loading, error, data, refetch } = useQuery(ARTICLE_QUERY, {
    variables: {
      query: {
        value: queryText
      }
    }
  });

  const onChange = (e) => {
    setInputText(e.target.value);
  }

  const onSubmit = (e) => {
    setQueryText(inputText);

    e.preventDefault();
  }

  const renderList = () => {
    if (loading) return <p>Loading...</p>;
    if (error) return <p>Error</p>;
    return(
      <>
        <span>とーたる: {data.articles.totalCount}件</span>
      　{data.articles.facets.map( ({key, count}, index) => <Facet key={index} name={key} count={count} /> )}
        {data.articles.nodes.map( node => <Article key={node.id} {...node} /> )}
      </>
    )
  }

  return(
    <div>
      <form onSubmit={onSubmit}>
        <input type='text' value={inputText} onChange={onChange}/>
      </form>
      {renderList()}
    </div>
  )
}

export default () => (
  <Provider>
    <ArticleList />
  </Provider>
)
