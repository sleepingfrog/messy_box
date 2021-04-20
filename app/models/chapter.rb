# frozen_string_literal: true
# == Schema Information
#
# Table name: chapters
#
#  id          :bigint           not null, primary key
#  page_count  :integer
#  page_offset :integer
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :bigint           not null
#
# Indexes
#
#  index_chapters_on_book_id               (book_id)
#  index_chapters_on_book_id_and_position  (book_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#
class Chapter < ApplicationRecord
  belongs_to :book
  has_many :pages, lambda { order(number: :asc) }, inverse_of: :chapter

  validates :position, presence: true, uniqueness: { scope: :book }
  validates :page_count, :page_offset, presence: true
end
