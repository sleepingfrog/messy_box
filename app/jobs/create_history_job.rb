class CreateHistoryJob < ApplicationJob
  queue_as :default

  def perform(entry)
    Entry.transaction do
      entry.lock!
      history = entry.histories.build
      history.image.attach(io: screenshot(entry.url, wait_time: entry.wait_time), filename: 'screenshot.png')
      history.save!
    end

    histories = entry.histories.last(2)
    CreateComparisonJob.perform_later(*histories) if histories.size == 2
  end

  private

    def screenshot(url, wait_time: 1)
      caps = Selenium::WebDriver::Remote::Capabilities.firefox
      driver = Selenium::WebDriver.for(:remote, url: ENV['SELENIUM_HUB_URL'], capabilities: caps)
      driver.get(url)
      sleep(wait_time) # wait for rendering
      result = nil
      Tempfile.open(['ss', '.png']) do |f|
        driver.save_full_page_screenshot(f.path)
        result = StringIO.new(f.read)
      end
      result
    ensure
      driver&.quit
    end
end
