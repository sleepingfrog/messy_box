# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Book < ApplicationRecord
  has_many :chapters, lambda { order(position: :asc) }, inverse_of: :book
  has_many :pages, lambda { order([Chapter.arel_attribute(:position).asc, Page.arel_attribute(:number).asc]) }, through: :chapters
  has_many :frames
end
