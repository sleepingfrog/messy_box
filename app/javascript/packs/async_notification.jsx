import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom';
import consumer from "../channels/consumer"

const App = () => {
  const [receive, setReceive] = useState(true);

  const onClick = (e) => {
    setReceive(prev => !prev);
  }

  return(
    <div>
      { receive && <Notification /> }
      receive <button type='button' onClick={onClick} >{ receive.toString() }</button>
    </div>
  )
}

const Notification = () => {
  useEffect(() => {
    const subscription = consumer.subscriptions.create({
      channel: 'AsyncNotificationChannel'
    },
    {
      received(data) { console.log(data) }
    })

    const cleanup = () => {
      consumer.subscriptions.remove(subscription)
    }

    return cleanup;
  })

  return(
    <div>
      Cable
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
