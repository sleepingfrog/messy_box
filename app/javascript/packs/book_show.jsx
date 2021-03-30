import React, { useEffect, useState, useContext } from 'react';
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
import { Rect, Layer, Stage, Line } from 'react-konva';

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
          pageSize {
            width
            height
          }
          frames {
            id
          }
        }
      }
      frames {
        id
        x
        y
        text
        color
        frameSize {
          name
          height
          width
        }
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
  frames: [],
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
              <Link to={`${match.url}/chapters/${position}`} >chapter:{position}</Link>
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

function FrameList() {
  const {frames} = useContext(BookContext);
  return(
    <ul>
      {
        frames.map(({id, color, text, frameSize, x}) => (
          <li key={id}>
            <div>
              <span style={{background: color}}>　</span>
              width: {frameSize.width}
              height: {frameSize.height}
              text: {text}
              { x !== null ? <span>allodated</span> : null }
            </div>
          </li>
        ))
      }
    </ul>
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
              <Link to={`${match.url}/pages/${number}`} >page: {number}</Link>
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

const PageContext = React.createContext({
  width: 0,
  height: 0,
  xCount: 0,
  yCount: 0,
})

function Page({chapterPosition}) {
  const { number } = useParams();
  const bookData = useContext(BookContext);
  const data = bookData.chapters.find((chapter) => chapter.position === parseInt(chapterPosition)).pages.find((page) => page.number === parseInt(number))
  const renderFrames = () => (
    data.frames.map((frame) => <Frame key={frame.id} {...frame} />)
  )
  const allocatedIds = data.frames.map(({id}) => id)
  const allocatedFrames = bookData.frames.filter(({id}) => allocatedIds.includes(id))
  const pageSetting = {
    width: 800,
    height: 600,
    xCount: data.pageSize.width,
    yCount: data.pageSize.height,
  }

  return(
    <>
      <Stage width={pageSetting.width} height={pageSetting.height}>
        <PageContext.Provider value={pageSetting}>
          <GridLayer />
          <FrameLayer frames={allocatedFrames}/>
        </PageContext.Provider>
      </Stage>
      <FrameList />
    </>
  )
}

function GridLayer() {
  const {width, height, xCount, yCount} = useContext(PageContext);
  const stroke = 'red'
  const renderGridLines = () => {
    const horizontals = [...Array(xCount + 1)].map((n, index) => (
      <Line key={"x" + index} points={[index * (width / xCount), 0, index * (width / xCount), height]} stroke={stroke}  strokeWidth={0.5}/>
    ))
    const verticals = [...Array(yCount + 1)].map((n, index) => (
      <Line key={"y" + index} points={[0, index * (height / yCount), width, index * (height / yCount)]} stroke={stroke}  strokeWidth={0.5}/>
    ))

    return(
      [
        ...horizontals,
        ...verticals,
      ]
    )
  }

  return(
    <Layer listening={false}>
      {renderGridLines()}
    </Layer>
  )
}

function FrameLayer({frames}) {
  return(
    <Layer>
      {frames.map((frame) => (
        <AllocatedFrame key={frame.id} {...frame} />
      ))}
    </Layer>
  )
}

function AllocatedFrame({x, y, frameSize, text, color}) {
  const page = useContext(PageContext);
  const blockSize = {
    width: page.width / page.xCount,
    height: page.height / page.yCount,
  }

  const [isDragging, setIsDragging] = useState(false)
  const [position, setPosition] = useState({
    x: x * blockSize.width,
    y: y * blockSize.height,
  })

  useEffect(() => {
    setPosition({
      x: x * blockSize.width,
      y: y * blockSize.height,
    })
  }, [x, y, isDragging])

  const calcPosition = ({x, y}) => ({
      x: Math.round(x / blockSize.width),
      y: Math.round(y / blockSize.height),
  })

  const onDragEnd = (e) => {
    setIsDragging(false)
  }

  const onDragMove = (e) => {
    setPosition({
      x: e.target._lastPos.x,
      y: e.target._lastPos.y,
    })
  }
  const onDragStart = (e) => {
    setIsDragging(true)
  }

  return(
    <Rect
      x={position.x}
      y={position.y}
      width={frameSize.width * blockSize.width}
      height={frameSize.height * blockSize.height}
      fill={color}
      draggable={true}
      onDragEnd={onDragEnd}
      onDragStart={onDragStart}
      onDragMove={onDragMove}
      _useStrictMode
    />
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
