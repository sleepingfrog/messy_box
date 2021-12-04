# == Schema Information
#
# Table name: comparisons
#
#  id         :bigint           not null, primary key
#  diff       :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  after_id   :bigint           not null
#  before_id  :bigint           not null
#
# Indexes
#
#  index_comparisons_on_after_id   (after_id)
#  index_comparisons_on_before_id  (before_id)
#
# Foreign Keys
#
#  fk_rails_...  (after_id => histories.id)
#  fk_rails_...  (before_id => histories.id)
#
class Comparison < ApplicationRecord
  belongs_to :before, class_name: 'History'
  belongs_to :after, class_name: 'History'

  has_one_attached :image
end
