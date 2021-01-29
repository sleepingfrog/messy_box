import React from 'react';
import ReactDOM from 'react-dom';
import { Rect, Layer, Stage } from 'react-konva';

export default () => {
  return(
    <Stage width={300} height={300} >
      <Layer>
        <Rect stroke='blue' strokeWidth={4} x={5} y={5} width={290} height={290} />
        <Rect fill='112233' x={10} y={100} width={100} height={100} />
      </Layer>
    </Stage>
  )
}
