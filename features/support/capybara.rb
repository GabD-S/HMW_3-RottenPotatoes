require 'capybara/cucumber'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5
