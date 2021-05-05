class AsyncNotificationJob < ApplicationJob
  queue_as :default

  def perform(category: 1, messages: "")
    case category
    when 1
      ActionCable.server.broadcast('async_notification', messages)
    when 2
      ActionCable.server.broadcast('async_notification2', messages)
    else
      raise 'unknown category'
    end
  end
end
