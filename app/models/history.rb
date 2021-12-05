# frozen_string_literal: true
# == Schema Information
#
# Table name: histories
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :bigint           not null
#
# Indexes
#
#  index_histories_on_entry_id  (entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (entry_id => entries.id)
#
class History < ApplicationRecord
  belongs_to :entry

  has_one :comparison_with_after, class_name: 'Comparison', foreign_key: :before_id, dependent: :destroy
  has_one :comparison_with_before, class_name: 'Comparison', foreign_key: :after_id, dependent: :destroy

  has_one_attached :image
end
