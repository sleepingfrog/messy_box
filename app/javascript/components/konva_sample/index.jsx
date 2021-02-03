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
      </PageContext.Provider>
    </Stage>
  )
}
