# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  number       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chapter_id   :bigint           not null
#  page_size_id :bigint
#
# Indexes
#
#  index_pages_on_chapter_id             (chapter_id)
#  index_pages_on_chapter_id_and_number  (chapter_id,number) UNIQUE
#  index_pages_on_page_size_id           (page_size_id)
#
# Foreign Keys
#
#  fk_rails_...  (chapter_id => chapters.id)
#
class Page < ApplicationRecord
  belongs_to :chapter
  belongs_to :page_size
  has_many :frames

  validates :number,
    uniqueness: { scope: :chapter },
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: lambda { |record| record.chapter.page_count }
    }

  scope :book_page_number, lambda { |numbers|
    joins(:chapter).where(
      (Chapter.arel_table[:page_offset] + Page.arel_table[:number]).in(numbers)
    )
  }

  scope :find_by_book_page_number, lambda { |number|
    book_page_number(number).first
  }

  def page_number
    chapter.page_offset + number
  end
end
