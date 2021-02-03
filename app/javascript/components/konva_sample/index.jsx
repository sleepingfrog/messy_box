import React, { useContext } from 'react';
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

const Frame = ({id, x, y, width, height, color}) => {
  const page = useContext(PageContext);
  const blockSize = {
    width: page.width / page.xCount,
    height: page.height / page.yCount,
  }
  return(
    <Rect
      key={id}
      x={x * blockSize.width}
      y={y * blockSize.height}
      width={width * blockSize.width}
      height={height * blockSize.height}
      fill={color}
    />
  )
}

const FrameLayer = ({frames}) => {
  const renderFrames = () => (
    frames.map((frame) => (
      <Frame key={frame.id} {...frame}/>
    ))
  )

  return(
    <Layer>
      {
        frames.map((frame) =>(
          <Frame key={frame.id} {...frame} />
        ))
      }
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

  return(
    <Stage width={pageSetting.width} height={pageSetting.height}>
      <PageContext.Provider value={pageSetting}>
        <GridLayer />
        <FrameLayer frames={INITIAL_FRAMES} />
      </PageContext.Provider>
    </Stage>
  )
}
