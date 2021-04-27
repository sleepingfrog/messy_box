import React, { useEffect  } from 'react';
import ReactDOM from 'react-dom';
import consumer from "../channels/consumer"

const App = () => {
  useEffect(() => {
    consumer.subscriptions.create({
      channel: 'AsyncNotificationChannel'
    },
    {
      received(data) { console.log(data) }
    })
  })

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
