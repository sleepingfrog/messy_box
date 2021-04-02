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
import { Rect, Layer, Stage, Line, Text } from 'react-konva';

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

function FrameList({handleClick, handleMouseOver, handleMouseOut}) {
  const {frames} = useContext(BookContext);
  return(
    <ul>
      {
        frames.map(({id, color, text, frameSize, x}) => (
          <li key={id}>
            <div onClick={(e) => handleClick(e, id)} onMouseOver={(e) => handleMouseOver(e, id)} onMouseOut={handleMouseOut}>
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
  const [allocatedFrames, setAllocatedFrames] = useState([])
  useEffect(() => {
    const allocatedIds = data.frames.map(({id}) => id)
    setAllocatedFrames(
      bookData.frames.filter(({id}) => allocatedIds.includes(id))
    )
  }, [data.frames])
  const pageSetting = {
    width: 800,
    height: 600,
    xCount: data.pageSize.width,
    yCount: data.pageSize.height,
  }

  const [shadow, setShadow] = useState(null)

  const handleAllocatedFrameDragStart = (e, id) => {
    const frame = allocatedFrames.find((frame) => frame.id === id)
    setAllocatedFrames(
      [
        ...allocatedFrames.filter((frame) => frame.id !== id), frame
      ]
    )
  }
  const handleAllocatedFrameDragMove = (e, id, rawPosition) => {
    const frame = allocatedFrames.find((frame) => frame.id === id)
    let x = rawPosition.x
    let y = rawPosition.y
    if(x < 0) {
      x = 0
    } else if(x > pageSetting.xCount - frame.frameSize.width) {
      x = pageSetting.xCount - frame.frameSize.width
    }

    if(y < 0) {
      y = 0
    } else if(y > pageSetting.yCount - frame.frameSize.height) {
      y = pageSetting.yCount - frame.frameSize.height
    }

    const tmpShadow = { ...frame, x, y }
    if(FramesCollisionCHeck(tmpShadow, allocatedFrames.filter((frame) => frame.id !== id))) {
      console.log('collision!')
    } else {
      setShadow(tmpShadow)
    }
  }
  const handleAllocatedFrameDragEnd = (e, id) => {
    const frame = allocatedFrames.find((frame) => frame.id === id)
    setAllocatedFrames(
      [
        ...allocatedFrames.filter((frame) => frame.id !== id), {...frame, x: shadow.x, y: shadow.y}
      ]
    )
    setShadow(null)
  }


  const handleFrameListClick = (e, id) => {
    const frame = bookData.frames.find(frame => frame.id === id)
    const position = FindFreeSpace({width: pageSetting.xCount, height: pageSetting.yCount}, allocatedFrames, frame.frameSize)
    if(position) {
      // unique の制御が必要
      setAllocatedFrames(
        [...allocatedFrames, {...frame, x: position.x, y: position.y}]
      )
    }

  }

  const handleFrameListMouseOver = (e, id) => {
    // dnd との排他制御が必要
    const frame = bookData.frames.find(frame => frame.id === id)
    const position = FindFreeSpace({width: pageSetting.xCount, height: pageSetting.yCount}, allocatedFrames, frame.frameSize)
    if(position) {
      setShadow({...frame, x: position.x, y: position.y})
    }
  }
  const handleFrameListMouseOut = (e, id) => {
    // dnd との排他制御が必要
    if(shadow) { setShadow(null) }
  }

  return(
    <>
      <Stage width={pageSetting.width} height={pageSetting.height}>
        <PageContext.Provider value={pageSetting}>
          <GridLayer />
          <ShadowLayer shadow={shadow} />
          <FrameLayer
            frames={allocatedFrames}
            {
              ...{
                handleDragStart: handleAllocatedFrameDragStart,
                handleDragMove: handleAllocatedFrameDragMove,
                handleDragEnd: handleAllocatedFrameDragEnd
              }
            }
          />
        </PageContext.Provider>
      </Stage>
      <FrameList
        handleClick={handleFrameListClick}
        handleMouseOver={handleFrameListMouseOver}
        handleMouseOut={handleFrameListMouseOut}
      />
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

function ShadowLayer({shadow}) {
  if(!shadow) {
    return(null)
  }
  return(
    <Layer listening={false}>
      <AllocatedFrame key={'shadow'} {...shadow} forceColor={"#DDD"} />
    </Layer>
  )

}
function FrameLayer({frames, handleDragStart, handleDragMove, handleDragEnd}) {
  return(
    <Layer>
      {frames.map((frame) => (
        <AllocatedFrame key={frame.id} {...frame} {...{handleDragStart, handleDragMove, handleDragEnd}}  />
      ))}
    </Layer>
  )
}

function AllocatedFrame({id, x, y, frameSize, text, color, handleDragStart, handleDragMove, handleDragEnd, forceColor}) {
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
    handleDragEnd(e, id)
  }

  const onDragMove = (e) => {
    setPosition({
      x: e.target._lastPos.x,
      y: e.target._lastPos.y,
    })
    handleDragMove(e, id, calcPosition({x: e.target._lastPos.x, y: e.target._lastPos.y}))
  }
  const onDragStart = (e) => {
    setIsDragging(true)
    handleDragStart(e, id)
  }

  const decoretedText = `text:${text}\nframeSize: ${frameSize.name}`

  return(
    <>
      <Rect
        x={position.x}
        y={position.y}
        width={frameSize.width * blockSize.width}
        height={frameSize.height * blockSize.height}
        fill={ forceColor ? forceColor : color}
        draggable={true}
        onDragEnd={onDragEnd}
        onDragStart={onDragStart}
        onDragMove={onDragMove}
        _useStrictMode
      />
      <Text
        x={position.x}
        y={position.y}
        width={frameSize.width * blockSize.width}
        height={frameSize.height * blockSize.height}
        text={decoretedText}
        fill={"#000"}
        fontSize={18}
        align={'center'}
        padding={5}
        listening={false}
      />
    </>
  )
}

function Frame({id, x, y, text, color}) {
  return(
    <div>
      {id}, {x}, {y}, {text}, {color}
    </div>
  )
}

function FrameCollisionCheck(frame, other) {
  return(
    (frame.x <= other.x + other.frameSize.width - 1)
    && (other.x <= frame.x + frame.frameSize.width - 1)
    && (frame.y <= other.y + other.frameSize.height - 1)
    && (other.y <= frame.y + frame.frameSize.height - 1)
  )
}
function FramesCollisionCHeck(frame, others) {
  return(
    others.some( other => FrameCollisionCheck(other, frame) )
  )
}

function FindFreeSpace(pageSize, allocatedFrames, frameSize) {
  for(let i = 0; i < pageSize.height - frameSize.height + 1; i++) {
    for(let j = 0; j < pageSize.width - frameSize.width + 1; j++) {
      if(FramesCollisionCHeck({frameSize, x: j, y: i}, allocatedFrames)) {
        continue
      } else {
        return { x: j, y: i }
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
