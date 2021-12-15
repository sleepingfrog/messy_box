# frozen_string_literal: true
# == Schema Information
#
# Table name: entries
#
#  id         :bigint           not null, primary key
#  url        :text
#  wait       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Entry < ApplicationRecord
  has_many :histories, dependent: :destroy

  validates :url, presence: true
  validate :correct_url

  def wait_time
    wait.presence || 1
  end

  private

    def correct_url
      if !URI.regexp(%w[http https]).match?(url) || URI.parse(url).host.blank?
        errors.add(:url, :invalid)
      end
    end
end
