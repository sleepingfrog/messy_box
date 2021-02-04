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

  test 'book_page_number scope' do
    book = Book.new
    book.chapters.build(position: 1, page_offset: 0, page_count: 3) do |chapter|
      chapter.pages.build(number: 1)
      chapter.pages.build(number: 2)
      chapter.pages.build(number: 3)
    end
    book.chapters.build(position: 2, page_offset: 3, page_count: 3) do |chapter|
      chapter.pages.build(number: 1)
      chapter.pages.build(number: 2)
      chapter.pages.build(number: 3)
    end
    book.save!

    pages = book.pages.book_page_number([2, 3, 4])
    assert_equal(
      [[1, 0, 2], [1, 0, 3], [2, 3, 1]],
      pages.map{ |page| [page.chapter.position, page.chapter.page_offset, page.number] }
    )

    page = book.pages.find_by_book_page_number(5)
    assert_equal(
      [2, 3, 2],
      [page.chapter.position, page.chapter.page_offset, page.number]
    )
  end

  test 'page_number' do
    chapter = Chapter.new(page_offset: 1)
    page = chapter.pages.build(number: 2)
    assert_equal(3, page.page_number)
  end
end
