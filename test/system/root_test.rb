# frozen_string_literal: true
require "application_system_test_case"

class RootTest < ApplicationSystemTestCase
  test "visiting the root" do
    visit root_url
    assert_selector "h1", text: "Home#index"
  end
end
