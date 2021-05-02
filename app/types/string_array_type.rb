class StringArrayType < ActiveModel::Type::Value
  def cast_value(value)
    Array(value).map(&:to_s)
  end
end