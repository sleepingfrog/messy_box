# frozen_string_literal: true
class AsyncNotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from('async_notification')
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
