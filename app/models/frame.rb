class Frame < ApplicationRecord
  belongs_to :frame_size
  belongs_to :page, optional: true
  belongs_to :book
end
