import React from 'react';
import ReactDOM from 'react-dom';

const App = () => {
  return(
    <div>
      hello
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
