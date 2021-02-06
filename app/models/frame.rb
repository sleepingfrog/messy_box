class Frame < ApplicationRecord
  belongs_to :frame_size
  belongs_to :page
  belongs_to :book
end
