class CreateHistoryJob < ApplicationJob
  queue_as :default

  def perform(entry)
    Entry.transaction do
      entry.lock!
      history = entry.histories.build
      history.image.attach(io: screenshot(entry.url, wait_time: entry.wait_time), filename: 'screenshot.png')
      history.save!
    end
  end

  private

  def screenshot(url, wait_time: 1)
    caps = Selenium::WebDriver::Remote::Capabilities.firefox
    driver = Selenium::WebDriver.for(:remote, url: ENV['SELENIUM_HUB_URL'], capabilities: caps)
    driver.get(url)
    sleep wait_time # wait for rendering
    result = nil
    Tempfile.open(['ss', '.png']) { |f|
      driver.save_full_page_screenshot(f.path)
      result = StringIO.new f.read
    }
    result
  ensure
    driver&.quit
  end
end
