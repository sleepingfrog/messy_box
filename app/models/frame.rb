# frozen_string_literal: true
# == Schema Information
#
# Table name: frames
#
#  id            :bigint           not null, primary key
#  color         :string
#  text          :text
#  x             :integer
#  y             :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  book_id       :bigint           not null
#  frame_size_id :bigint           not null
#  page_id       :bigint
#
# Indexes
#
#  index_frames_on_book_id        (book_id)
#  index_frames_on_frame_size_id  (frame_size_id)
#  index_frames_on_page_id        (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (frame_size_id => frame_sizes.id)
#  fk_rails_...  (page_id => pages.id)
#
class Frame < ApplicationRecord
  belongs_to :frame_size
  belongs_to :page, optional: true
  belongs_to :book
end
