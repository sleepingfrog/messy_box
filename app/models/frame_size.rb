class FrameSize < ApplicationRecord
  validates :width, :height, :name, presence: true
end
