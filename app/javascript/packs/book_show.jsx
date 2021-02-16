import React from 'react';
import ReactDOM from 'react-dom';
import {
  BrowserRouter as Router,
  Link,
  Route,
  Switch,
  useRouteMatch,
  useParams
} from 'react-router-dom';

const App = () => {
  return(
    <>
      <div>books show</div>
      <Router>
        <Book />
      </Router>
    </>
  )
}

function Book(){
  let match = useRouteMatch('/books/:bookId');
  return(
    <>
      <div>
        <nav>
          <ul>
            <li>
              <Link to={`${match.url}/pages/1`}>Page1</Link>
            </li>
            <li>
              <Link to={`${match.url}/pages/2`}>Page2</Link>
            </li>
            <li>
              <Link to={`${match.url}/pages/3`}>Page3</Link>
            </li>
            <li>
              <Link to={`${match.url}`}>Home</Link>
            </li>
          </ul>
        </nav>
      </div>

      <Switch>
        <Route path={`${match.path}/pages/:pageNumber`}>
          <Pages />
        </Route>
        <Route path={match.path}>
          <h3>home</h3>
        </Route>
      </Switch>
    </>
  )
}

function Pages() {
  let { bookId, pageNumber }= useParams()
  return(
    <div>book: {bookId} pages: {pageNumber}</div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
