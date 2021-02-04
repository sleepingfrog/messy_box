# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chapter_id :bigint           not null
#
# Indexes
#
#  index_pages_on_chapter_id             (chapter_id)
#  index_pages_on_chapter_id_and_number  (chapter_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chapter_id => chapters.id)
#
class Page < ApplicationRecord
  belongs_to :chapter

  validates :number,
    uniqueness: { scope: :chapter },
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: lambda { |record| record.chapter.page_count }
    }
end
