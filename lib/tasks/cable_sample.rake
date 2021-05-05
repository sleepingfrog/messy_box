task cable_sample: :environment do
  ActionCable.server.config.logger = Logger.new(STDOUT)

  200.times do |i|
    sleep 1
    AsyncNotificationJob.perform_later(category: (i % 2) + 1, messages: "notification-#{i}")
  end
end
