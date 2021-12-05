# frozen_string_literal: true
Rails.application.reloader.to_prepare do
  ActiveModel::Type.register(:string_array, StringArrayType)
end
