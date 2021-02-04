require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test 'number range validation' do
    page = Page.new
    page.chapter = Chapter.new(page_count: 3)

    page.number = nil
    assert(page.invalid?)
    assert(page.errors.added?(:number, :not_a_number, value: nil))

    page.number = 0
    assert(page.invalid?)
    assert(page.errors.added?(:number, :greater_than_or_equal_to, count: 1, value: 0))

    page.number = 4
    assert(page.invalid?)
    assert(page.errors.added?(:number, :less_than_or_equal_to, count: 3, value: 4))
  end

  test 'number uniqueness validation' do
    chapter = Chapter.new(
      book: Book.new,
      position: 1,
      page_offset: 0,
      page_count: 3
    )

    chapter.pages.build(number: 1)

    chapter.save!

    page = chapter.pages.build(number: 1)

    assert(page.invalid?)
    assert(page.errors.added?(:number, :taken, value: 1))
  end
end
