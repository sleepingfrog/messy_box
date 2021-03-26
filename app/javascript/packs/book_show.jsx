import React, { useContext } from 'react';
import ReactDOM from 'react-dom';
import { createCache, createClient } from '../utils/apollo';
import { ApolloProvider, useQuery, gql  } from '@apollo/client';
import {
  BrowserRouter as Router,
  Link,
  Route,
  Switch,
  useRouteMatch,
  useParams,
  useLocation,
  Redirect,
} from 'react-router-dom';

const BOOK_QUERY = gql`
  query BookType($id: ID!) {
    book(id: $id) {
      id
      title
      description
      chapters {
        position
        pageCount
        pages {
          number
          frames {
            id
            x
            y
            text
            color
          }
        }
      }
      frames {
        id
        x
        y
        text
        color
      }
    }
  }
`

const App = () => {
  return(
    <>
      <div>books show</div>
      <ApolloProvider client={createClient(createCache())}>
        <Router>
          <BookRoute />
        </Router>
      </ApolloProvider>
    </>
  )
}

function BookRoute() {
  let match = useRouteMatch('/books/:bookId');
  return(
    <Switch>
      <Route path={match.path} >
        <Book />
      </Route>
    </Switch>
  )
}

const BookContext = React.createContext({
  title: "",
  description: "",
  chapters: [],
})

function Book(){
  let match = useRouteMatch('/books/:bookId');
  let { pathname } = useLocation();
  const { bookId } = useParams();
  const { loading, error, data } = useQuery(BOOK_QUERY, {
    variables: {id: bookId}
  })

  if (loading) { return("loading...") }
  if (error) { return("error...") }

  return(
    <BookContext.Provider value={data.book}>
      <BookInfo />
      <nav>
        <ul>
          {data.book.chapters.map(({position}) =>(
            <li key={position}>
              <Link to={`${match.url}/chapters/${position}`} >{position}</Link>
            </li>
          )) }
        </ul>
      </nav>
      <Switch>
        <Redirect from="/:url*(/+)" to={pathname.slice(0, -1)} />
        <Route path={`${match.url}/chapters/:position`}>
          <Chapter />
        </Route>
      </Switch>
    </BookContext.Provider>
  )
}

function BookInfo() {
  const data = useContext(BookContext);
  const renderChapterInfo = () => {
    return(
      <div> chapters
        {data.chapters.map(({position, pageCount}) => <div key={position}> <div>position: {position} count: {pageCount}</div></div>)
        }
      </div>
    )
  }

  return(
    <div>
      <div> title: {data.title} </div>
      <div> description: {data.description} </div>
      {renderChapterInfo()}
    </div>
  )
}

function Chapter() {
  let match = useRouteMatch('/books/:bookId/chapters/:position');
  const { position } = useParams();
  const bookData = useContext(BookContext);
  const data = bookData.chapters.find((chapter) => chapter.position === parseInt(position))
  return(
    <div>
      {data.position}, {data.pageCount}
      <nav>
        <ul>
          {data.pages.map(({number}) =>(
            <li key={number}>
              <Link to={`${match.url}/pages/${number}`} >{number}</Link>
            </li>
          ))}
        </ul>
      </nav>
      <Switch>
        <Route path={`${match.url}/pages/:number`}>
          <Page chapterPosition={position}/>
        </Route>
      </Switch>
    </div>
  )
}

function Page({chapterPosition}) {
  const { number } = useParams();
  const bookData = useContext(BookContext);
  const data = bookData.chapters.find((chapter) => chapter.position === parseInt(chapterPosition)).pages.find((page) => page.number === parseInt(number))
  const renderFrames = () => (
    data.frames.map((frame) => <Frame key={frame.id} {...frame} />)
  )
  return(
    <div>
      {data.number}
      {renderFrames()}
    </div>
  )
}

function Frame({id, x, y, text, color}) {
  return(
    <div>
      {id}, {x}, {y}, {text}, {color}
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
