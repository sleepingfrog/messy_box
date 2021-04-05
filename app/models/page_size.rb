# == Schema Information
#
# Table name: page_sizes
#
#  id         :bigint           not null, primary key
#  height     :integer          not null
#  name       :string           not null
#  width      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PageSize < ApplicationRecord
end
