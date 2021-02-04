require 'test_helper'

class ChapterTest < ActiveSupport::TestCase

  test 'page_order' do
    book = Book.new
    chapter = book.chapters.build(position: 1, page_offset: 0, page_count: 3)
    chapter.pages.build(number: 3)
    chapter.pages.build(number: 1)
    chapter.pages.build(number: 2)
    book.save!

    assert_equal(
      [1, 2, 3],
      chapter.pages.map(&:number)
    )
  end

  test 'position validation' do
    book = Book.new
    book.chapters.build(position: 1, page_offset: 0, page_count: 3)
    book.save!

    chapter = book.chapters.build

    assert(chapter.invalid?)
    assert(chapter.errors.added?(:position, :blank))

    chapter.position = 1

    assert(chapter.invalid?)
    assert(chapter.errors.added?(:position, :taken, value: 1))

    assert(chapter.errors.added?(:page_count, :blank))
    assert(chapter.errors.added?(:page_offset, :blank))

    chapter.position = 2
    chapter.page_count = 1
    chapter.page_offset = 1
    assert(chapter.save)
  end
end
