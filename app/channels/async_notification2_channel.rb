class AsyncNotification2Channel < ApplicationCable::Channel
  def subscribed
    stream_from "async_notification2"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
