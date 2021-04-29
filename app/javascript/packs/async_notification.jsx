import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom';
import consumer from "../channels/consumer"

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
  const appendNotification = (data) => {
    setNotifications((prev) => {
      console.log('received', data)
      if (prev.length >= NOTIFICATION_SIZE) {
        return ([...prev.slice(prev.length - (NOTIFICATION_SIZE - 1)), data])
      } else {
        return ([...prev, data])
      }
    })
  }
  const renderNotifications = () => {
    return (
      notifications.map(data => <div key={data}>{data}</div>)
    )
  }

  useEffect(() => {
    const subscription = consumer.subscriptions.create({
      channel: 'AsyncNotificationChannel'
    },
      {
        received(data) { appendNotification(data) }
      })

    const cleanup = () => {
      console.log('cleanup!')
      consumer.subscriptions.remove(subscription)
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
