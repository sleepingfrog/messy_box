# frozen_string_literal: true
require "test_helper"
require 'capybara'

Capybara.server_host = '0.0.0.0'
Capybara.server_port = 4000
Capybara.app_host = "http://#{ENV['APP_HOST']}:4000"
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :chrome, screen_size: [900, 900], options: { url: ENV["SELENIUM_HUB_URL"] }

  def setup
    # require "rake"
    # Rails.application.load_tasks
    # Rake::Task["webpacker:compile"].execute
    super
  end
end
