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
end
