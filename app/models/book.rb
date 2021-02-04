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
  has_many :chapters
  has_many :pages, through: :chapters
end
