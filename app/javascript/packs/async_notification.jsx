import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom';
import consumer from "../channels/consumer"

window.cable = consumer;

const App = () => {
  const [receive, setReceive] = useState(true);

  const onClick = (e) => {
    setReceive(prev => !prev);
  }

  return (
    <div>
      receive {receive.toString()}<button type='button' onClick={onClick} >or not</button>
      {receive && <Notification />}
    </div>
  )
}

const NOTIFICATION_SIZE = 10

const Notification = () => {
  const [notifications, setNotifications] = useState([]);
  const appendNotification = (data, category) => {
    console.log('received', data)
    const message = `category:${category} messages: ${data}`
    setNotifications((prev) => {
      if (prev.length >= NOTIFICATION_SIZE) {
        return ([...prev.slice(prev.length - (NOTIFICATION_SIZE - 1)), message])
      } else {
        return ([...prev, message])
      }
    })
  }
  const renderNotifications = () => {
    return (
      notifications.map(data => <div key={data}>{data}</div>)
    )
  }

  useEffect(() => {
    window.cable.subscriptions.create({
      channel: 'AsyncNotificationChannel'
    },
    {
      received(data) { appendNotification(data, 1) }
    })
    window.cable.subscriptions.create({
      channel: 'AsyncNotification2Channel'
    },
    {
      received(data) { appendNotification(data, 2) }
    })

    const cleanup = () => {
      console.log('cleanup!');
      const channelIDs = [
        { channle: }
      ]
      window.cable.subscriptions.findAll()
    }

    return cleanup;
  }, [])

  return (
    <div>
      Cable
      {renderNotifications()}
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('root')
  )
})
