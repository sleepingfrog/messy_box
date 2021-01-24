import React, { useState, useEffect } from 'react';
import { createCache, createClient } from '../../utils/apollo';
import { ApolloProvider, useQuery, gql  } from '@apollo/client';

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

const Article = ({id, title, body, tags}) => {
  return(
    <div key={id}>
      <p><span>{title}</span></p>
      {tags.map(({name}, index) => <Tag key={index} name={name} />)}
      <p>{body}</p>
    </div>
  )
}

const Tag = ({name}) => (
  <div>
    <span>{name}</span>
  </div>
)

const Facet = ({facet}) => {
  return(
    <label>{facet.key}({facet.count})</label>
  )
}

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
      　{data.articles.facets.map( (facet, index) => <Facet key={index} facet={facet} /> )}
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
