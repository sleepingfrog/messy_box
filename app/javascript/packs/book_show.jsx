import React, { useEffect, useState, useContext } from 'react';
import ReactDOM from 'react-dom';
import { createCache, createClient } from '../utils/apollo';
import { ApolloProvider, useQuery, gql, useMutation } from '@apollo/client';
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
import { Rect, Layer, Stage, Line, Text, Label, Tag } from 'react-konva';

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

const PAGE_ALLOCATE = gql`
  mutation pageAllocate($input: PageAllocateInput!){
    pageAllocate(input: $input){
      status
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

function FrameList({frames, handleClick, handleMouseOver, handleMouseOut}) {
  return(
    <ul>
      {
        frames.map( frame => (
          <li key={frame.id}>
            <FrameListItem
              {...frame}
              handleClick={handleClick}
              handleMouseOver={handleMouseOver}
              handleMouseOut={handleMouseOut}
            />
          </li>
        ))
      }
    </ul>
  )
}

function FrameListItem({id, color, text, frameSize, x, handleClick, handleMouseOver, handleMouseOut}) {
  const [mouseOver, setMouseOver] = useState(false)
  const onMouseOver = (e) => {
    setMouseOver(true)
    handleMouseOver(e, id)
  }
  const onMouseOut = (e) => {
    setMouseOver(false)
    handleMouseOut(e)
  }

  const style = {
    background: (mouseOver ? '#DDD' : null)
  }

  return(
    <div style={style} onClick={(e) => handleClick(e, id)} onMouseOver={onMouseOver} onMouseOut={onMouseOut}>
      <span style={{background: color}}>　</span>
      width: {frameSize.width}
      height: {frameSize.height}
      text: {text}
      a: {mouseOver}
      { x !== null ? <span>allodated</span> : null }
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
  const [notAllocatedframes, setNotAllocatedFrames] = useState([])

  const [frameHistory, pushFrameHistory, resetFrameHistory, {canUndo, undo, canRedo, redo}] = useSimpleUndo([])

  useEffect(() => {
    const allocatedIds = data.frames.map(({id}) => id)
    const newAllocatedFrames = bookData.frames.filter(({id}) => allocatedIds.includes(id))
    setAllocatedFrames(newAllocatedFrames)
    resetFrameHistory()
    pushFrameHistory(newAllocatedFrames)
    setNotAllocatedFrames(
      bookData.frames.filter(({id}) => !allocatedIds.includes(id))
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
    } else {
      setShadow(tmpShadow)
    }
  }
  const handleAllocatedFrameDragEnd = (e, id) => {
    const frame = allocatedFrames.find((frame) => frame.id === id)
    const newAllocatedFrames = [ ...allocatedFrames.filter((frame) => frame.id !== id), {...frame, x: shadow.x, y: shadow.y} ]
    setAllocatedFrames(newAllocatedFrames)
    pushFrameHistory(newAllocatedFrames)
    setShadow(null)
  }


  const handleFrameListClick = (e, id) => {
    const frame = bookData.frames.find(frame => frame.id === id)
    const position = FindFreeSpace({width: pageSetting.xCount, height: pageSetting.yCount}, allocatedFrames, frame.frameSize)
    if(position) {
      // unique の制御が必要
      const newAllocatedFrames = [...allocatedFrames, {...frame, x: position.x, y: position.y}]
      setAllocatedFrames(newAllocatedFrames)
      pushFrameHistory(newAllocatedFrames)
      setNotAllocatedFrames(
        notAllocatedframes.filter(frame => frame.id !== id)
      )
    }
    if(shadow) { setShadow(null) }
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

  const handleAllocatedFrameRemove = (e, id) => {
    const newAllocatedFrames = allocatedFrames.filter(frame => frame.id !== id)
    setAllocatedFrames(newAllocatedFrames)
    pushFrameHistory(newAllocatedFrames)
    setNotAllocatedFrames([
      ...notAllocatedframes, bookData.frames.find(frame => frame.id === id)
    ])
  }

  const [pageAllocate, {loading, error}] = useMutation(PAGE_ALLOCATE)

  const allocation = (e) => {
    // need refetch or update cache ...?
    pageAllocate({
      variables: {
        input: {
          bookId: bookData.id,
          chapterPosition: parseInt(chapterPosition),
          pageNumber: parseInt(number),
            frames: allocatedFrames.map(frame => ({ id: frame.id, x: frame.x, y: frame.y }))
        }
      }
    })
  }


  const renderSaveButton = () => {
    if(loading) { return "loading..." }
    if(error) { return "error!" }

    return(
      <button type='button' onClick={allocation}>save!</button>
    )
  }


  const renderUndoButton = () => {
    if(!canUndo) { return null }
    const handleClick = (e) => {
      const currentFrames = undo()
      setAllocatedFrames(currentFrames);
      const allocatedIds =  currentFrames.map( frame => frame.id )
      setNotAllocatedFrames(
        bookData.frames.filter(({id}) => !allocatedIds.includes(id))
      )
    }
    return(
      <button type='button' onClick={handleClick}>undo</button>
    )
  }

  const renderRedoButton = () => {
    if(!canRedo) { return null }
    const handleClick = (e) => {
      const currentFrames = redo()
      setAllocatedFrames(currentFrames)
      const allocatedIds =  currentFrames.map( frame => frame.id )
      setNotAllocatedFrames(
        bookData.frames.filter(({id}) => !allocatedIds.includes(id))
      )
    }
    return(
      <button type='button' onClick={handleClick}>redo</button>
    )
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
                handleDragEnd: handleAllocatedFrameDragEnd,
                handleFrameRemove: handleAllocatedFrameRemove,
              }
            }
          />
        </PageContext.Provider>
      </Stage>
      <div>
        {renderSaveButton()}
        {renderUndoButton()}
        {renderRedoButton()}
      </div>
      <FrameList
        frames={notAllocatedframes}
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
function FrameLayer({frames, handleDragStart, handleDragMove, handleDragEnd, handleFrameRemove}) {
  return(
    <Layer>
      {frames.map((frame) => (
        <AllocatedFrame key={frame.id} {...frame} {...{handleDragStart, handleDragMove, handleDragEnd, handleFrameRemove}}  />
      ))}
    </Layer>
  )
}

function AllocatedFrame({id, x, y, frameSize, text, color, handleDragStart, handleDragMove, handleDragEnd, forceColor, handleFrameRemove}) {
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

  const closeButtonClick = (e) => {
    handleFrameRemove(e, id);
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
      <Label
        x={position.x}
        y={position.y}
        opacity={0.75}
      >
        <Tag
          fill={'black'}
          onClick={closeButtonClick}
        />
        <Text
          listening={false}
          width={30}
          height={30}
          text={'x'}
          fontSize={20}
          padding={3}
          fill={'white'}
          align={'center'}
          verticalAlign={'center'}
        />
      </Label>
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

function useSimpleUndo() {
  const [history, setHistory] = useState([])
  const [index, setIndex] = useState(-1)

  const canUndo = index > 0 && history.length > 0
  const canRedo = index < history.length - 1 && history.length > 0

  const undo = () => {
    setIndex(index - 1)
    return(history[index - 1])
  }

  const redo = () => {
    setIndex(index + 1)
    return(history[index + 1])
  }

  const reset = () => {
    setIndex(-1)
    setHistory([])
  }

  const push = (value) => {
    if(history.length === index + 1){
      // tail
      setHistory(prev => [...prev, value])
      setIndex(prev => prev + 1)
    } else {
      setHistory([...history.slice(0, index + 1), value])
      setIndex(prev => prev + 1)
    }
  }

  const currentValue = history[index]

  return(
    [history, push, reset, {canUndo, undo, canRedo, redo, currentValue }]
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
