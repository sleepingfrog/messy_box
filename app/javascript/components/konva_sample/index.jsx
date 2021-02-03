import React, { useContext, useState, useEffect } from 'react';
import ReactDOM from 'react-dom';
import { Rect, Layer, Stage, Line } from 'react-konva';

const PageContext = React.createContext({
  width: 0,
  height: 0,
  xCount: 0,
  yCount: 0,
})

const GridLayer = () => {
  const {width, height, xCount, yCount} = useContext(PageContext);
  const stroke = 'blue'

  const renderGridLines = () => {
    const horizontals = [...Array(xCount + 1)].map((n, index) => (
      <Line key={"x" + index} points={[index * (width / xCount), 0, index * (width / xCount), height]} stroke={'red'}  strokeWidth={0.5}/>
    ))
    const verticals = [...Array(yCount + 1)].map((n, index) => (
      <Line key={"y" + index} points={[0, index * (height / yCount), width, index * (height / yCount)]} stroke={'red'}  strokeWidth={0.5}/>
    ))
    return(
      [
        ...horizontals,
        ...verticals,
      ]
    )
  }
  return(
    <Layer>
      {renderGridLines()}
    </Layer>
  )
}

const Frame = ({id, x, y, width, height, color, handleDragEnd, handleDragStart, handleDragMove}) => {
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
    const position = calcPosition({x: e.target._lastPos.x, y: e.target._lastPos.y})
    handleDragEnd(e, id, position);
    setIsDragging(false)
  }

  const onDragMove = (e) => {
    const position = calcPosition({x: e.target._lastPos.x, y: e.target._lastPos.y})
    handleDragMove(e, id, position);
    setPosition({
      x: e.target._lastPos.x,
      y: e.target._lastPos.y,
    })
  }
  const onDragStart = (e) => {
    setIsDragging(true)
    handleDragStart(e, id)
  }

  return(
    <Rect
      key={id}
      x={position.x}
      y={position.y}
      width={width * blockSize.width}
      height={height * blockSize.height}
      fill={isDragging ? '#ccccFF' : color}
      draggable={true}
      onDragEnd={onDragEnd}
      onDragStart={onDragStart}
      onDragMove={onDragMove}
      _useStrictMode
    />
  )
}

const FrameLayer = ({frames, handleDragStart, handleDragEnd, handleDragMove}) => {
  return(
    <Layer>
      {
        frames.map((frame) =>(
          <Frame key={frame.id} {...frame} handleDragStart={handleDragStart} handleDragEnd={handleDragEnd} handleDragMove={handleDragMove} />
        ))
      }
    </Layer>
  )
}

const ShadowLayer = ({shadow}) => {
  if(!shadow) { return null }

  const page = useContext(PageContext);
  const blockSize = {
    width: page.width / page.xCount,
    height: page.height / page.yCount,
  }

  return(
    <Layer>
      <Rect
        x={shadow.x * blockSize.width}
        y={shadow.y * blockSize.height}
        width={shadow.width * blockSize.width}
        height={shadow.height * blockSize.height}
        fill={'#8888'}
        _useStrictMode
      />
    </Layer>
  )
}

const INITIAL_FRAMES = [
  { id: 0, x: 0, y: 0, width: 1, height: 2, color: '#ffbbee' },
  { id: 1, x: 1, y: 3, width: 8, height: 2, color: '#123123' },
  { id: 2, x: 3, y: 1, width: 1, height: 3, color: '#FF0012' },
]

export default () => {
  const pageSetting = {
    width: 900,
    height: 300,
    xCount: 12,
    yCount: 8,
  }

  const [frames, setFrames] = useState(INITIAL_FRAMES);
  const [shadow, setShadow] = useState(null);

  const handleDragEnd = (e, frameId, position) => {
    const frame = frames.find(({id}) => frameId === id)
    setFrames(
      [
        ...frames.filter(({id}) => id !== frameId), {...frame, x: position.x, y: position.y}
      ]
    )
  }

  const handleDragMove = (e, frameId, position) => {
    const frame = frames.find(({id}) => frameId === id)
    setShadow({...frame, x: position.x, y: position.y})
  }

  const handleDragStart = (e, frameId) => {
    const frame = frames.find(({id}) => frameId === id)
    setFrames(
      [
        ...frames.filter(({id}) => id !== frameId), frame
      ]
    )
  }

  return(
    <Stage width={pageSetting.width} height={pageSetting.height}>
      <PageContext.Provider value={pageSetting}>
        <GridLayer />
        <ShadowLayer shadow={shadow} />
        <FrameLayer frames={frames} handleDragStart={handleDragStart} handleDragEnd={handleDragEnd} handleDragMove={handleDragMove}/>
      </PageContext.Provider>
    </Stage>
  )
}
