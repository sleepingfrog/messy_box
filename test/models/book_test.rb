# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test 'chapter_order' do
    book = Book.new
    book.chapters.build(position: 3, page_count: 1, page_offset: 2)
    book.chapters.build(position: 1, page_count: 1, page_offset: 0)
    book.chapters.build(position: 2, page_count: 1, page_offset: 1)
    book.save!

    assert_equal([1, 2, 3], book.chapters.map(&:position))
  end

  test 'page_order' do
    book = Book.new
    page_size = PageSize.new(
      name: 'page_size1',
      width: 3,
      height: 4,
    )
    book.chapters.build(position: 3, page_count: 2, page_offset: 4).tap do |chapter|
      chapter.pages.build(number: 2, page_size: page_size)
      chapter.pages.build(number: 1, page_size: page_size)
    end
    book.chapters.build(position: 1, page_count: 2, page_offset: 0).tap do |chapter|
      chapter.pages.build(number: 2, page_size: page_size)
      chapter.pages.build(number: 1, page_size: page_size)
    end
    book.chapters.build(position: 2, page_count: 2, page_offset: 2).tap do |chapter|
      chapter.pages.build(number: 2, page_size: page_size)
      chapter.pages.build(number: 1, page_size: page_size)
    end

    book.save!

    assert_equal(
      [1, 2, 3, 4, 5, 6],
      book.pages.map { |page| page.number + page.chapter.page_offset }
    )
  end
end
