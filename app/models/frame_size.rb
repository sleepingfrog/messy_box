# == Schema Information
#
# Table name: frame_sizes
#
#  id         :bigint           not null, primary key
#  height     :integer          not null
#  name       :text             not null
#  width      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class FrameSize < ApplicationRecord
  has_many :frames
  validates :width, :height, :name, presence: true
end
