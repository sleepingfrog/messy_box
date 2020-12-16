require 'selenium-webdriver'

class SeleniumJob < ApplicationJob
  queue_as :default

  def perform(*args)
    uri = args.first
    driver = setup_driver
    driver.get(uri)
    screenshot = driver.screenshot_as(:png)

    # stub
    File.open("./tmp/#{job_id}.png", 'wb') { |f| f.write(screenshot) }
  end

  private

    def setup_driver
      driver = Selenium::WebDriver.for(:remote, url: selenium_url, desired_capabilities: :firefox)
    end

    def selenium_url
      ENV['SELENIUM_URL']
    end
end
